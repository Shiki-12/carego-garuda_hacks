import { api } from "encore.dev/api";
import { db } from "../db/db";

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
        
        await db.exec`
            INSERT INTO activity_logs (user_id, user_name, user_role, action, detail)
            SELECT id, name, role, 'UPDATE_PROFILE', 'User updated profile' FROM users WHERE id = ${req.userId}
        `;
        
        return { success: true };
    }
);
