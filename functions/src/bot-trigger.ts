/*
import { onRequest } from "firebase-functions/v2/https";
import { Bot } from "grammy";

const bot = new Bot(process.env.BOT_SECRETKEY!);

bot.command("start", (ctx) => ctx.reply("Welcome! Up and running."));

export const sendBotMessage = onRequest(async (request, response) => {
    bot.start();
    response.send("Bot started!");
});
*/