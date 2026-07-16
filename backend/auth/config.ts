import { secret } from "encore.dev/config";

// Gmail SMTP configuration for sending OTPs via Email
export const GMAIL_USER = secret("GMAIL_USER");
export const GMAIL_PASS = secret("GMAIL_PASS");

// WAHA (WhatsApp HTTP API) configuration for sending OTPs via WhatsApp
export const WAHA_URL = secret("WAHA_URL");
export const WAHA_SESSION = secret("WAHA_SESSION");
