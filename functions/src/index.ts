import * as admin from "firebase-admin";

admin.initializeApp();

// Export all functions from the auth.ts file
export * from "./auth";

// Export Telegram bot functions
export * from "./bot-trigger";

// Export logging functions for error handling
export * from "./logging";

// Export avatar proxy function
export * from "./avatar-proxy";

// Export image proxy function
export * from "./image-proxy";

// Export PDF converter functions
export * from "./pdf-converter";