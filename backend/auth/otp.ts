import { EMAILJS_SERVICE_ID, EMAILJS_TEMPLATE_ID, EMAILJS_PUBLIC_KEY, EMAILJS_PRIVATE_KEY, WAHA_URL, WAHA_SESSION } from "./config";
import emailjs from "@emailjs/nodejs";

export async function sendOtpEmail(email: string, otp: string) {
    const serviceId = EMAILJS_SERVICE_ID();
    const templateId = EMAILJS_TEMPLATE_ID();
    const publicKey = EMAILJS_PUBLIC_KEY();
    const privateKey = EMAILJS_PRIVATE_KEY();

    if (!serviceId || !templateId || !publicKey) {
        console.warn("[EmailJS] Missing EMAILJS secrets. Falling back to console.");
        console.log(`[Email] Send OTP ${otp} to ${email}`);
        return;
    }

    try {
        await emailjs.send(
            serviceId,
            templateId,
            {
                to_email: email,
                otp_code: otp,
            },
            {
                publicKey: publicKey,
                privateKey: privateKey,
            }
        );
        console.log(`[EmailJS] OTP ${otp} sent successfully to ${email}`);
    } catch (error) {
        console.error("[EmailJS] Failed to send OTP email:", error);
        throw new Error("Gagal mengirim email OTP via EmailJS");
    }
}

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
    if (method === "email") {
        await sendOtpEmail(identifier, otp);
    } else if (method === "whatsapp") {
        await sendOtpWaha(identifier, otp);
    } else {
        // Fallback for unknown methods
        console.log(`[${method.toUpperCase()}] Send OTP ${otp} to ${identifier} (Console Fallback)`);
    }
}
