import { onCall } from "firebase-functions/v2/https";
import { logger } from "firebase-functions";
import * as admin from "firebase-admin";

interface ErrorLogData {
  error: string;
  stackTrace?: string;
  userId: string;
  operation: string;
  timestamp: string;
  platform: string;
  version: string;
  severity: 'critical' | 'warning' | 'info';
  additionalData?: Record<string, any>;
}

/**
 * Firebase Function для логирования ошибок от Telegram WebApp
 */
export const logError = onCall(async (request) => {
  try {
    const data = request.data as ErrorLogData;
    
    // Валидируем данные
    if (!data.error || !data.userId || !data.operation) {
      throw new Error('Missing required fields: error, userId, operation');
    }
    
    // Логируем в Firebase Functions logs
    logger.error('TelegramWebApp Error', {
      error: data.error,
      stackTrace: data.stackTrace,
      userId: data.userId,
      operation: data.operation,
      timestamp: data.timestamp,
      platform: data.platform,
      version: data.version,
      severity: data.severity,
      additionalData: data.additionalData,
    });
    
    // Сохраняем в Firestore для анализа
    const firestore = admin.firestore();
    const collection = getCollectionName(data.severity);
    
    await firestore.collection(collection).add({
      ...data,
      receivedAt: admin.firestore.FieldValue.serverTimestamp(),
      processed: false,
    });
    
    // Для критичных ошибок - можно добавить отправку уведомлений
    if (data.severity === 'critical') {
      await handleCriticalError(data);
    }
    
    return { success: true, message: 'Error logged successfully' };
    
  } catch (error) {
    logger.error('Failed to log error', error);
    throw new Error('Failed to log error');
  }
});

/**
 * Определяет название коллекции на основе типа ошибки
 */
function getCollectionName(severity: string): string {
  switch (severity) {
    case 'critical':
      return 'critical_errors';
    case 'warning':
      return 'warnings';
    case 'info':
      return 'info_logs';
    default:
      return 'app_logs';
  }
}

/**
 * Обработка критичных ошибок
 */
async function handleCriticalError(data: ErrorLogData): Promise<void> {
  try {
    // Здесь можно добавить:
    // - Отправку уведомлений в Telegram админам
    // - Отправку email уведомлений
    // - Интеграцию с системами мониторинга (Sentry, etc.)
    
    logger.warn('Critical error detected', {
      userId: data.userId,
      operation: data.operation,
      error: data.error,
    });
    
    // Пример: отправка в специальную коллекцию для срочного реагирования
    const firestore = admin.firestore();
    await firestore.collection('urgent_alerts').add({
      type: 'critical_error',
      userId: data.userId,
      operation: data.operation,
      error: data.error,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      resolved: false,
    });
    
  } catch (error) {
    logger.error('Failed to handle critical error', error);
  }
}

/**
 * Функция для получения статистики ошибок
 */
export const getErrorStats = onCall(async (request) => {
  try {
    const firestore = admin.firestore();
    const now = new Date();
    const yesterday = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    
    // Получаем количество ошибок за последние 24 часа
    const criticalSnapshot = await firestore
      .collection('critical_errors')
      .where('receivedAt', '>=', yesterday)
      .count()
      .get();
      
    const warningsSnapshot = await firestore
      .collection('warnings')
      .where('receivedAt', '>=', yesterday)
      .count()
      .get();
    
    return {
      criticalErrors: criticalSnapshot.data().count,
      warnings: warningsSnapshot.data().count,
      period: '24h',
      timestamp: now.toISOString(),
    };
    
  } catch (error) {
    logger.error('Failed to get error stats', error);
    throw new Error('Failed to get error stats');
  }
});

/**
 * Функция для очистки старых логов
 */
export const cleanupOldLogs = onCall(async (request) => {
  try {
    const firestore = admin.firestore();
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - 30); // Удаляем логи старше 30 дней
    
    const collections = ['critical_errors', 'warnings', 'info_logs', 'app_logs'];
    let totalDeleted = 0;
    
    for (const collectionName of collections) {
      const snapshot = await firestore
        .collection(collectionName)
        .where('receivedAt', '<', cutoffDate)
        .limit(500) // Ограничиваем за один раз
        .get();
      
      const batch = firestore.batch();
      snapshot.docs.forEach((doc) => {
        batch.delete(doc.ref);
      });
      
      if (!snapshot.empty) {
        await batch.commit();
        totalDeleted += snapshot.size;
      }
    }
    
    logger.info(`Cleanup completed: ${totalDeleted} logs deleted`);
    
    return {
      success: true,
      deletedCount: totalDeleted,
      cutoffDate: cutoffDate.toISOString(),
    };
    
  } catch (error) {
    logger.error('Failed to cleanup old logs', error);
    throw new Error('Failed to cleanup old logs');
  }
}); 