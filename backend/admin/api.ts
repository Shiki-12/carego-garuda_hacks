import { api } from "encore.dev/api";
import { db } from "../db/db";
import bcrypt from "bcryptjs";

export interface AdminUserResponse {
    data: any[];
}

export interface ActivityLog {
    id: number;
    user_id: number;
    user_name: string;
    user_role: string;
    action: string;
    detail: string;
    created_at: string;
}

export interface LogsResponse {
    data: ActivityLog[];
}

export interface CreateUserRequest {
    name: string;
    email: string;
    role: string;
    password?: string;
    phone?: string;
}

export interface CreateRecRequest {
    title: string;
    description: string;
    image_url?: string;
    service_type: string;
    action_url: string;
}

export interface SuccessResponse {
    success: boolean;
}

export const getUsers = api(
    { expose: true, method: "GET", path: "/admin/users" },
    async (): Promise<AdminUserResponse> => {
        const result = await db.query`
            SELECT id, name, email, role, phone, photo_url, created_at 
            FROM users 
            ORDER BY created_at DESC
        `;
        const users = [];
        for await (const row of result) users.push(row);
        return { data: users };
    }
);

export const createUser = api(
    { expose: true, method: "POST", path: "/admin/users" },
    async (req: CreateUserRequest): Promise<SuccessResponse> => {
        const hash = req.password ? await bcrypt.hash(req.password, 10) : "";
        const user = await db.queryRow`
            INSERT INTO users (name, email, phone, role, password_hash)
            VALUES (${req.name}, ${req.email}, ${req.phone}, ${req.role}, ${hash})
            RETURNING id
        `;
        if (user) {
            await db.exec`INSERT INTO wallets (user_id, balance) VALUES (${user.id}, 0)`;
        }
        return { success: true };
    }
);

export const getLogs = api(
    { expose: true, method: "GET", path: "/admin/activity-logs" },
    async (): Promise<LogsResponse> => {
        const result = await db.query`
            SELECT id, user_id, user_name, user_role, action, detail, created_at 
            FROM activity_logs 
            ORDER BY created_at DESC 
            LIMIT 100
        `;
        const logs = [];
        for await (const row of result) logs.push(row as any);
        return { data: logs };
    }
);

export const createRecommendation = api(
    { expose: true, method: "POST", path: "/admin/recommendations" },
    async (req: CreateRecRequest): Promise<SuccessResponse> => {
        await db.exec`
            INSERT INTO recommendations (title, description, image_url, service_type, action_url, is_active)
            VALUES (${req.title}, ${req.description}, ${req.image_url}, ${req.service_type}, ${req.action_url}, TRUE)
        `;
        return { success: true };
    }
);

export const deleteRecommendation = api(
    { expose: true, method: "DELETE", path: "/admin/recommendations/:id" },
    async (req: { id: number }): Promise<SuccessResponse> => {
        await db.exec`DELETE FROM recommendations WHERE id = ${req.id}`;
        return { success: true };
    }
);
