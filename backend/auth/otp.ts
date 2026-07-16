import nodemailer from "nodemailer";
import { GMAIL_USER, GMAIL_PASS, WAHA_URL, WAHA_SESSION } from "./config";

export async function sendOtpEmail(email: string, otp: string) {
    const user = GMAIL_USER();
    const pass = GMAIL_PASS();
    if (!user || !pass) {
        console.warn("[Email] GMAIL_USER or GMAIL_PASS secret is not set. Falling back to console.");
        console.log(`[Email] Send OTP ${otp} to ${email}`);
        return;
    }

    const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
            user,
            pass
        }
    });

    const mailOptions = {
        from: user,
        to: email,
        subject: "CareGo Verification Code",
        text: `Your CareGo verification code is: ${otp}. It will expire in 5 minutes.`,
        html: `
            <h2>CareGo Verification</h2>
            <p>Your verification code is: <strong>${otp}</strong></p>
            <p>It will expire in 5 minutes. Do not share this code with anyone.</p>
        `
    };

    try {
        await transporter.sendMail(mailOptions);
        console.log(`[Email] OTP ${otp} sent successfully to ${email}`);
    } catch (error) {
        console.error("[Email] Failed to send OTP email:", error);
        throw new Error("Gagal mengirim email OTP");
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
        console.log(`[${method.toUpperCase()}] Send OTP ${otp} to ${identifier}`);
    }
}
