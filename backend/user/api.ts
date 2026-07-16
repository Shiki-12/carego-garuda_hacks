import { api } from "encore.dev/api";
import { db } from "../db/db";
import { logActivity } from "../utils/logger";

export interface BalanceRequest {
    userId: number;
}

export interface BalanceResponse {
    balance: number;
}

export interface UpdateProfileRequest {
    userId: number;
    phone?: string;
    photoBase64?: string;
}

export interface SuccessResponse {
    success: boolean;
    message?: string;
}

export const balance = api(
    { expose: true, method: "POST", path: "/user/balance" },
    async (req: BalanceRequest): Promise<BalanceResponse> => {
        const wallet = await db.queryRow`SELECT balance FROM wallets WHERE user_id = ${req.userId}`;
        if (!wallet) throw new Error("Wallet tidak ditemukan");
        return { balance: wallet.balance };
    }
);

export const updateProfile = api(
    { expose: true, method: "POST", path: "/user/profile/update" },
    async (req: UpdateProfileRequest): Promise<SuccessResponse> => {
        const userExists = await db.queryRow`SELECT id FROM users WHERE id = ${req.userId}`;
        if (!userExists) throw new Error("User tidak ditemukan");

        if (req.phone && req.photoBase64) {
            await db.exec`UPDATE users SET phone = ${req.phone}, photo_url = ${req.photoBase64} WHERE id = ${req.userId}`;
        } else if (req.phone) {
            await db.exec`UPDATE users SET phone = ${req.phone} WHERE id = ${req.userId}`;
        } else if (req.photoBase64) {
            await db.exec`UPDATE users SET photo_url = ${req.photoBase64} WHERE id = ${req.userId}`;
        }
        
        await logActivity(req.userId, 'UPDATE_PROFILE', 'User updated profile');
        
        return { success: true };
    }
);
