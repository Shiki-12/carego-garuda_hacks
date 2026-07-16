import { secret } from "encore.dev/config";



// WAHA (WhatsApp HTTP API) configuration for sending OTPs via WhatsApp
export const WAHA_URL = secret("WAHA_URL");
export const WAHA_SESSION = secret("WAHA_SESSION");
