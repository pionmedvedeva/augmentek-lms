import { onRequest } from 'firebase-functions/v2/https';
import { getStorage } from 'firebase-admin/storage';
import { initializeApp, getApps } from 'firebase-admin/app';
import * as logger from 'firebase-functions/logger';

// Initialize Firebase Admin if not already initialized
if (getApps().length === 0) {
  initializeApp();
}

interface TelegramFile {
  file_id: string;
  file_unique_id: string;
  file_size?: number;
  file_path?: string;
}

interface TelegramGetFileResponse {
  ok: boolean;
  result?: TelegramFile;
  description?: string;
}

interface TelegramUserProfilePhotos {
  ok: boolean;
  result?: {
    total_count: number;
    photos: Array<Array<{
      file_id: string;
      file_unique_id: string;
      width: number;
      height: number;
      file_size?: number;
    }>>;
  };
}

/**
 * Firebase Function для получения аватаров пользователей Telegram
 * Обходит CORS проблемы SVG аватаров, получая изображения через Bot API
 */
export const getAvatarProxy = onRequest(
  {
    cors: true,
    timeoutSeconds: 30,
    memory: '256MiB',
    secrets: ['BOT_TOKEN'],
  },
  async (req, res) => {
    // CORS headers
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'GET') {
      res.status(405).json({ error: 'Method not allowed' });
      return;
    }

    try {
      const { userId } = req.query;

      if (!userId || typeof userId !== 'string') {
        res.status(400).json({ error: 'userId parameter is required' });
        return;
      }

      logger.info(`Getting avatar for user: ${userId}`);

      // Получаем BOT_TOKEN из environment variables
      const botToken = process.env.BOT_TOKEN;
      if (!botToken) {
        logger.error('BOT_TOKEN not configured');
        res.status(500).json({ error: 'Bot token not configured' });
        return;
      }

      // Проверяем кэш в Firebase Storage
      const storage = getStorage();
      const bucket = storage.bucket();
      const avatarPath = `avatars/${userId}.png`;
      const file = bucket.file(avatarPath);

      try {
        const [exists] = await file.exists();
        if (exists) {
          // Проверяем возраст файла (кэшируем на 24 часа)
          const [metadata] = await file.getMetadata();
          const createdTime = new Date(metadata.timeCreated!);
          const now = new Date();
          const hoursDiff = (now.getTime() - createdTime.getTime()) / (1000 * 60 * 60);

          if (hoursDiff < 24) {
            logger.info(`Returning cached avatar for user: ${userId}`);
            const [fileBuffer] = await file.download();
            
            res.set('Content-Type', 'image/png');
            res.set('Cache-Control', 'public, max-age=86400'); // 24 hours
            res.set('Access-Control-Allow-Origin', '*');
            
            res.send(fileBuffer);
            return;
          }
        }
      } catch (error) {
        logger.info(`No cached avatar found for user: ${userId}`);
      }

      // Получаем фото профиля через Telegram Bot API
      const photosResponse = await fetch(
        `https://api.telegram.org/bot${botToken}/getUserProfilePhotos?user_id=${userId}&limit=1`
      );

      if (!photosResponse.ok) {
        throw new Error(`Telegram API error: ${photosResponse.status}`);
      }

      const photosData: TelegramUserProfilePhotos = await photosResponse.json();

      if (!photosData.ok || !photosData.result || photosData.result.total_count === 0) {
        logger.info(`No profile photos found for user: ${userId}`);
        res.status(404).send('No avatar found');
        return;
      }

      // Берем первое фото (самое большое разрешение)
      const photos = photosData.result.photos[0];
      const largestPhoto = photos[photos.length - 1]; // Последнее в массиве = наибольшее разрешение

      // Получаем информацию о файле
      const fileResponse = await fetch(
        `https://api.telegram.org/bot${botToken}/getFile?file_id=${largestPhoto.file_id}`
      );

      if (!fileResponse.ok) {
        throw new Error(`Failed to get file info: ${fileResponse.status}`);
      }

      const fileData: TelegramGetFileResponse = await fileResponse.json();

      if (!fileData.ok || !fileData.result?.file_path) {
        throw new Error('Failed to get file path from Telegram');
      }

      // Скачиваем изображение
      const imageResponse = await fetch(
        `https://api.telegram.org/file/bot${botToken}/${fileData.result.file_path}`
      );

      if (!imageResponse.ok) {
        throw new Error(`Failed to download image: ${imageResponse.status}`);
      }

      const imageBuffer = await imageResponse.arrayBuffer();

      // Сохраняем в Firebase Storage
      await file.save(Buffer.from(imageBuffer), {
        metadata: {
          contentType: 'image/png',
          cacheControl: 'public, max-age=86400', // 24 hours
        },
      });

      // Отдаем изображение напрямую как blob
      const [fileBuffer] = await file.download();
      
      res.set('Content-Type', 'image/png');
      res.set('Cache-Control', 'public, max-age=86400'); // 24 hours
      res.set('Access-Control-Allow-Origin', '*');
      
      logger.info(`Successfully served avatar for user: ${userId}`);
      res.send(fileBuffer);

    } catch (error) {
      logger.error('Error in getAvatarProxy:', error);
      res.status(500).json({ 
        error: 'Failed to get avatar',
        details: error instanceof Error ? error.message : 'Unknown error'
      });
    }
  }
); 