import { onRequest } from "firebase-functions/v2/https";
import { onDocumentCreated, onDocumentUpdated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";

const BOT_TOKEN = process.env.BOT_TOKEN || "";
const TELEGRAM_API_URL = `https://api.telegram.org/bot${BOT_TOKEN}`;

// Инициализация Firebase Admin
const db = getFirestore();
const storage = getStorage();

// Вспомогательная функция для отправки сообщений
async function sendMessage(chatId: number, text: string, replyMarkup?: any): Promise<any> {
  try {
    const fetch = (await import('node-fetch')).default;
    const response = await fetch(`${TELEGRAM_API_URL}/sendMessage`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        chat_id: chatId,
        text,
        parse_mode: 'HTML',
        reply_markup: replyMarkup
      })
    });
    return await response.json();
  } catch (error) {
    logger.error(`Error sending message to ${chatId}:`, error);
    return null;
  }
}

// Обработчик команды /start
async function handleStart(chatId: number, firstName: string) {
  const message = 
    `🎓 <b>Добро пожаловать в Augmentek LMS!</b>\n\n` +
    `Привет, ${firstName}! Теперь вы будете получать уведомления о:\n\n` +
    `📚 Новых курсах и уроках\n` +
    `📝 Домашних заданиях\n` +
    `✅ Результатах проверки\n` +
    `📎 Возможности загружать файлы\n\n` +
    `<b>Доступные команды:</b>\n` +
    `/homework - мои активные задания\n` +
    `/progress - прогресс по курсам\n` +
    `/help - справка\n\n` +
    `🚀 <a href="https://augmentek-lms.web.app">Открыть LMS</a>`;

  const replyMarkup = {
    inline_keyboard: [
      [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
    ]
  };

  await sendMessage(chatId, message, replyMarkup);
}

// Обработчик команды /homework
async function handleHomework(chatId: number) {
  try {
    const homeworkQuery = await db.collection('homework_submissions')
      .where('studentId', '==', chatId.toString())
      .orderBy('submittedAt', 'desc')
      .limit(10)
      .get();

    if (homeworkQuery.empty) {
      await sendMessage(chatId, 
        "📝 У вас пока нет активных домашних заданий.\n\n🚀 Откройте LMS чтобы посмотреть доступные курсы!",
        { inline_keyboard: [
          [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
        ]}
      );
      return;
    }

    let message = "📝 <b>Ваши активные домашние задания:</b>\n\n";
    
    homeworkQuery.docs.forEach((doc, index) => {
      const hw = doc.data();
      const statusEmoji = hw.status === 'pending' ? '⏳' : 
                         hw.status === 'approved' ? '✅' : '🔄';
      message += `${index + 1}. ${statusEmoji} <b>Урок ${hw.lessonId}</b>\n`;
      message += `   📅 Отправлено: ${new Date(hw.submittedAt.toDate()).toLocaleDateString('ru-RU')}\n`;
      if (hw.adminComment) {
        message += `   💬 Комментарий: ${hw.adminComment}\n`;
      }
      message += "\n";
    });

    await sendMessage(chatId, message, {
      inline_keyboard: [
        [{ text: "🚀 Открыть в LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
      ]
    });

  } catch (error) {
    logger.error("Error fetching homework:", error);
    await sendMessage(chatId, "❌ Ошибка при получении списка заданий. Попробуйте позже.");
  }
}

// Обработчик команды /progress
async function handleProgress(chatId: number) {
  try {
    const homeworkQuery = await db.collection('homework_submissions')
      .where('studentId', '==', chatId.toString())
      .get();

    const homework = homeworkQuery.docs.map(doc => doc.data());
    
    const stats = {
      activeCourses: new Set(homework.map(hw => hw.courseId).filter(Boolean)).size,
      completedHomework: homework.filter(hw => hw.status === 'approved').length,
      pendingHomework: homework.filter(hw => hw.status === 'pending').length,
      needsWorkHomework: homework.filter(hw => hw.status === 'needsWork').length,
      overallProgress: Math.round((homework.filter(hw => hw.status === 'approved').length / Math.max(homework.length, 1)) * 100)
    };

    const message = 
      `📊 <b>Ваш прогресс обучения:</b>\n\n` +
      `📚 Курсов изучается: ${stats.activeCourses}\n` +
      `📝 Заданий выполнено: ${stats.completedHomework}\n` +
      `⏳ Заданий на проверке: ${stats.pendingHomework}\n` +
      `🔄 Заданий на доработке: ${stats.needsWorkHomework}\n\n` +
      `🎯 Общий прогресс: ${stats.overallProgress}%`;

    await sendMessage(chatId, message, {
      inline_keyboard: [
        [{ text: "📊 Подробная статистика", web_app: { url: "https://augmentek-lms.web.app" } }]
      ]
    });

  } catch (error) {
    logger.error("Error fetching progress:", error);
    await sendMessage(chatId, "❌ Ошибка при получении статистики. Попробуйте позже.");
  }
}

// Обработчик команды /help
async function handleHelp(chatId: number) {
  const message = 
    "❓ <b>Справка по командам:</b>\n\n" +
    "🚀 /start - приветствие и основная информация\n" +
    "📝 /homework - список ваших активных заданий\n" +
    "📊 /progress - статистика обучения\n" +
    "❓ /help - эта справка\n\n" +
    "<b>Загрузка файлов:</b>\n" +
    "📎 Просто отправьте файл в чат - он автоматически прикрепится к активному заданию\n\n" +
    "<b>Поддерживаемые форматы:</b>\n" +
    "📄 Документы: PDF, DOC, DOCX, TXT\n" +
    "🖼 Изображения: JPG, PNG, GIF\n" +
    "🎵 Аудио: MP3, WAV, M4A\n" +
    "🎥 Видео: MP4, MOV, AVI";

  await sendMessage(chatId, message, {
    inline_keyboard: [
      [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
    ]
  });
}

// ===============================
// WEBHOOK ENDPOINT
// ===============================

export const telegramBot = onRequest({
  secrets: ["BOT_TOKEN"]
}, async (req, res) => {
  try {
    const update = req.body;
    
    if (!update.message) {
      res.status(200).send("OK");
      return;
    }

    const message = update.message;
    const chatId = message.chat.id;
    const text = message.text;
    const firstName = message.from?.first_name || "Пользователь";

    // Обработка команд
    if (text && text.startsWith('/')) {
      switch (text.split(' ')[0]) {
        case '/start':
          await handleStart(chatId, firstName);
          break;
        case '/homework':
          await handleHomework(chatId);
          break;
        case '/progress':
          await handleProgress(chatId);
          break;
        case '/help':
          await handleHelp(chatId);
          break;
        default:
          await sendMessage(chatId, 
            "🤖 Неизвестная команда. Используйте /help для списка доступных команд.",
            { inline_keyboard: [
              [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
            ]}
          );
      }
    } else if (message.document || message.photo || message.audio || message.video || message.voice) {
      // Обработка файлов
      await handleFileUpload(chatId, message);
    } else {
      // Обычное текстовое сообщение
      await sendMessage(chatId,
        "🤖 Привет! Я умею:\n\n" +
        "📝 Показывать ваши задания (/homework)\n" +
        "📊 Отображать прогресс (/progress)\n" +
        "📎 Принимать файлы для заданий\n\n" +
        "Для полного функционала используйте LMS:",
        { inline_keyboard: [
          [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
        ]}
      );
    }

    res.status(200).send("OK");
  } catch (error) {
    logger.error("Error in telegram webhook:", error);
    res.status(500).send("Internal Server Error");
  }
});

// Обработка загрузки файлов
async function handleFileUpload(chatId: number, message: any) {
  try {
    // Ищем активное задание пользователя
    const activeHomework = await findActiveHomeworkForUser(chatId);
    
    if (!activeHomework) {
      await sendMessage(chatId,
        "❌ У вас нет активных заданий для загрузки файла.\n\n" +
        "Чтобы загрузить файл, сначала создайте ответ на домашнее задание в LMS.",
        { inline_keyboard: [
          [{ text: "🚀 Открыть LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
        ]}
      );
      return;
    }

    await sendMessage(chatId, "📎 Загружаю файл...");

    // Получаем информацию о файле
    let fileId = "";
    let fileName = "";
    let fileSize = 0;

    if (message.document) {
      fileId = message.document.file_id;
      fileName = message.document.file_name || "document";
      fileSize = message.document.file_size || 0;
    } else if (message.photo) {
      const photo = message.photo[message.photo.length - 1];
      fileId = photo.file_id;
      fileName = `photo_${Date.now()}.jpg`;
      fileSize = photo.file_size || 0;
    } else if (message.audio) {
      fileId = message.audio.file_id;
      fileName = message.audio.file_name || `audio_${Date.now()}.mp3`;
      fileSize = message.audio.file_size || 0;
    } else if (message.video) {
      fileId = message.video.file_id;
      fileName = message.video.file_name || `video_${Date.now()}.mp4`;
      fileSize = message.video.file_size || 0;
    } else if (message.voice) {
      fileId = message.voice.file_id;
      fileName = `voice_${Date.now()}.oga`;
      fileSize = message.voice.file_size || 0;
    }

    // Проверяем размер файла (max 20MB)
    if (fileSize > 20 * 1024 * 1024) {
      await sendMessage(chatId, "❌ Файл слишком большой. Максимальный размер: 20 МБ");
      return;
    }

    // Загружаем файл в Firebase Storage
    const fileUrl = await uploadTelegramFile(fileId, fileName, activeHomework.id);
    
    // Обновляем задание с ссылкой на файл
    await updateHomeworkWithFile(activeHomework.id, fileUrl, fileName);

    await sendMessage(chatId,
      `✅ Файл успешно загружен!\n\n` +
      `📁 Файл: ${fileName}\n` +
      `📝 Задание: Домашнее задание\n\n` +
      `Файл прикреплен к вашему ответу на домашнее задание.`,
      { inline_keyboard: [
        [{ text: "🔍 Посмотреть в LMS", web_app: { url: "https://augmentek-lms.web.app" } }]
      ]}
    );

  } catch (error) {
    logger.error("Error handling file upload:", error);
    await sendMessage(chatId, "❌ Ошибка при загрузке файла. Попробуйте позже.");
  }
}

async function findActiveHomeworkForUser(telegramId: number) {
  try {
    const userId = telegramId.toString();
    
    // Ищем задания со статусом needsWork или последнее pending задание
    const needsWorkQuery = await db.collection('homework_submissions')
      .where('studentId', '==', userId)
      .where('status', '==', 'needsWork')
      .limit(1)
      .get();

    if (!needsWorkQuery.empty) {
      return {
        id: needsWorkQuery.docs[0].id,
        ...needsWorkQuery.docs[0].data()
      };
    }

    // Если нет заданий на доработке, ищем последнее pending
    const pendingQuery = await db.collection('homework_submissions')
      .where('studentId', '==', userId)
      .where('status', '==', 'pending')
      .orderBy('submittedAt', 'desc')
      .limit(1)
      .get();

    if (!pendingQuery.empty) {
      return {
        id: pendingQuery.docs[0].id,
        ...pendingQuery.docs[0].data()
      };
    }

    return null;
  } catch (error) {
    logger.error("Error finding active homework:", error);
    return null;
  }
}

async function uploadTelegramFile(fileId: string, fileName: string, homeworkId: string): Promise<string> {
  // Получаем файл от Telegram
  const fetch = (await import('node-fetch')).default;
  const fileInfoResponse = await fetch(`${TELEGRAM_API_URL}/getFile?file_id=${fileId}`);
  const fileInfo: any = await fileInfoResponse.json();
  
  if (!fileInfo.ok) throw new Error("Failed to get file info");
  
  const fileUrl = `https://api.telegram.org/file/bot${BOT_TOKEN}/${fileInfo.result.file_path}`;
  
  // Загружаем в Firebase Storage
  const bucket = storage.bucket();
  const filePath = `homework_files/${homeworkId}/${fileName}`;
  const file = bucket.file(filePath);
  
  // Скачиваем файл с Telegram и загружаем в Storage
  const response = await fetch(fileUrl);
  const buffer = await response.buffer();
  
  await file.save(buffer);
  await file.makePublic();
  
  return `https://storage.googleapis.com/${bucket.name}/${filePath}`;
}

async function updateHomeworkWithFile(homeworkId: string, fileUrl: string, fileName: string) {
  await db.collection('homework_submissions').doc(homeworkId).update({
    fileUrl,
    fileName,
    fileUploadedAt: new Date()
  });
}

// ===============================
// УВЕДОМЛЕНИЯ (TRIGGERS)
// ===============================

// Уведомление о новом домашнем задании
export const notifyNewHomework = onDocumentCreated(
  "homework_submissions/{submissionId}",
  async (event) => {
    const submission = event.data?.data();
    if (!submission) return;

    try {
      // Уведомляем всех админов
      const adminIds = [142170313]; // ID админов
      
      const message = 
        `🔔 <b>Новая работа на проверку!</b>\n\n` +
        `👤 Студент: ${submission.studentName || 'Неизвестен'}\n` +
        `📚 Задание: ${submission.lessonId}\n` +
        `📝 Ответ: ${submission.answer?.substring(0, 100) || 'Файл'}...\n` +
        `📅 Отправлено: ${new Date(submission.submittedAt.toDate()).toLocaleDateString('ru-RU')}`;

      const replyMarkup = {
        inline_keyboard: [
          [{ text: "🔍 Проверить", web_app: { url: "https://augmentek-lms.web.app/admin" } }]
        ]
      };

      for (const adminId of adminIds) {
        await sendMessage(adminId, message, replyMarkup);
      }

      logger.info(`Notified admins about new homework submission: ${event.params.submissionId}`);
    } catch (error) {
      logger.error("Error sending new homework notification:", error);
    }
  }
);

// Уведомление о результатах проверки
export const notifyHomeworkReviewed = onDocumentUpdated(
  "homework_submissions/{submissionId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();
    
    if (!before || !after) return;
    
    // Проверяем, изменился ли статус
    if (before.status === after.status) return;
    
    try {
      const message = after.status === 'approved' 
        ? `✅ <b>Ваша работа зачтена!</b>\n\n` +
          `📚 Задание: ${after.lessonId}\n` +
          `👨‍🏫 Преподаватель одобрил вашу работу.`
        : `🔄 <b>Работа отправлена на доработку</b>\n\n` +
          `📚 Задание: ${after.lessonId}\n` +
          `💬 Комментарий: ${after.adminComment || 'Нет комментария'}`;

      const replyMarkup = {
        inline_keyboard: [
          [{ text: "🔍 Посмотреть", web_app: { url: "https://augmentek-lms.web.app" } }]
        ]
      };

      const studentTelegramId = parseInt(after.studentId);
      if (!isNaN(studentTelegramId)) {
        await sendMessage(studentTelegramId, message, replyMarkup);
      }

      logger.info(`Notified student ${after.studentId} about homework review`);
    } catch (error) {
      logger.error("Error sending homework review notification:", error);
    }
  }
);