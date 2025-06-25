import { Bot } from "grammy";
import { logger } from "firebase-functions";

const BOT_TOKEN = process.env.BOT_TOKEN || "";
const WEBHOOK_URL = process.env.WEBHOOK_URL || "https://us-central1-augmentek-lms.cloudfunctions.net/telegramBot";

async function setupWebhook() {
  if (!BOT_TOKEN) {
    logger.error("BOT_TOKEN is not set");
    return;
  }

  const bot = new Bot(BOT_TOKEN);
  
  try {
    // Удаляем старый webhook
    await bot.api.deleteWebhook();
    logger.info("Old webhook deleted");
    
    // Устанавливаем новый webhook
    await bot.api.setWebhook(WEBHOOK_URL);
    logger.info(`Webhook set to: ${WEBHOOK_URL}`);
    
    // Проверяем информацию о webhook
    const webhookInfo = await bot.api.getWebhookInfo();
    logger.info("Webhook info:", webhookInfo);
    
  } catch (error) {
    logger.error("Error setting up webhook:", error);
  }
}

export { setupWebhook }; 