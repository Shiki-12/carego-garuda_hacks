import { WAHA_URL, WAHA_SESSION } from "./config";


export async function sendOtpWaha(phone: string, otp: string) {
    const url = WAHA_URL();
    const session = WAHA_SESSION() || "default";

    if (!url) {
        console.warn("[WAHA] WAHA_URL secret is not set. Falling back to console.");
        console.log(`[WhatsApp] Send OTP ${otp} to ${phone}`);
        return;
    }

    try {
        // WAHA API: POST /api/sendText
        const response = await fetch(`${url}/api/sendText`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            body: JSON.stringify({
                chatId: `${phone.replace(/[^0-9]/g, '')}@c.us`,
                text: `*CareGo*\n\nKode verifikasi Anda adalah: *${otp}*\nBerlaku selama 5 menit. Jangan bagikan kode ini.`,
                session: session
            }),
        });

        if (!response.ok) {
            const errText = await response.text();
            console.error(`[WAHA] API returned ${response.status}:`, errText);
            throw new Error(`WAHA API Error: ${response.statusText}`);
        }

        console.log(`[WAHA] OTP ${otp} sent successfully to ${phone}`);
    } catch (error) {
        console.error("[WAHA] Failed to send WhatsApp OTP:", error);
        throw new Error("Gagal mengirim WhatsApp OTP");
    }
}

export async function dispatchOtp(identifier: string, method: string, otp: string) {
    if (method === "whatsapp") {
        await sendOtpWaha(identifier, otp);
    } else {
        // Fallback for email or others since Gmail is removed
        console.log(`[${method.toUpperCase()}] Send OTP ${otp} to ${identifier} (Console Fallback)`);
    }
}
