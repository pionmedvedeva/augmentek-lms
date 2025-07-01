import { onRequest } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions';
import { getStorage } from 'firebase-admin/storage';

export const imageProxy = onRequest({
  cors: true,
  region: 'europe-west1',
}, async (req, res) => {
  try {
    // Только GET запросы
    if (req.method !== 'GET') {
      res.status(405).send('Method not allowed');
      return;
    }

    // Получаем путь к файлу из query параметра
    const imagePath = req.query.path as string;
    if (!imagePath) {
      res.status(400).send('Missing path parameter');
      return;
    }

    logger.info(`🖼️ Image proxy request for: ${imagePath}`);

    // Получаем файл из Firebase Storage
    const bucket = getStorage().bucket();
    const file = bucket.file(imagePath);

    // Проверяем что файл существует
    const [exists] = await file.exists();
    if (!exists) {
      logger.warn(`🖼️ Image not found: ${imagePath}`);
      res.status(404).send('Image not found');
      return;
    }

    // Получаем метаданные файла
    const [metadata] = await file.getMetadata();
    const contentType = metadata.contentType || 'image/jpeg';

    // Устанавливаем CORS заголовки для Telegram WebApp
    res.set({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': contentType,
      'Cache-Control': 'public, max-age=3600', // Кешируем на 1 час
    });

    // Создаем поток для чтения файла и отправки клиенту
    const stream = file.createReadStream();
    
    stream.on('error', (error) => {
      logger.error(`🖼️ Stream error for ${imagePath}:`, error);
      if (!res.headersSent) {
        res.status(500).send('Error reading image');
      }
    });

    stream.on('end', () => {
      logger.info(`🖼️ Successfully served image: ${imagePath}`);
    });

    // Отправляем файл клиенту
    stream.pipe(res);

  } catch (error) {
    logger.error('🖼️ Image proxy error:', error);
    if (!res.headersSent) {
      res.status(500).send('Internal server error');
    }
  }
}); 