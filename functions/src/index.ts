import * as admin from "firebase-admin";

admin.initializeApp();

// Export all functions from the auth.ts file
export * from "./auth";

// Export Telegram bot functions
export * from "./bot-trigger";