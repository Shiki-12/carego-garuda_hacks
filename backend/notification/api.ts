import { api } from "encore.dev/api";
import { db } from "../db/db";
import { logActivity } from "../utils/logger";

export interface UserRequest {
    userId: number;
}

export interface Notification {
    id: number;
    type: string;
    title: string;
    message: string;
    is_read: boolean;
    created_at: string;
}

export interface NotificationsResponse {
    data: Notification[];
}

export interface UnreadCountResponse {
    count: number;
}

export interface Preferences {
    booking_updates: boolean;
    promotions: boolean;
    system_updates: boolean;
}

export interface ReadNotificationRequest {
    userId: number;
    notificationId: number;
}

export interface SuccessResponse {
    success: boolean;
}

export const list = api(
    { expose: true, method: "POST", path: "/notifications/list" },
    async (req: UserRequest): Promise<NotificationsResponse> => {
        const result = await db.query`
            SELECT id, type, title, message, is_read, created_at
            FROM notifications
            WHERE user_id = ${req.userId}
            ORDER BY created_at DESC
            LIMIT 50
        `;
        const data: Notification[] = [];
        for await (const row of result) data.push(row as any);
        return { data };
    }
);

export const read = api(
    { expose: true, method: "POST", path: "/notifications/read" },
    async (req: ReadNotificationRequest): Promise<SuccessResponse> => {
        await db.exec`UPDATE notifications SET is_read = TRUE WHERE id = ${req.notificationId} AND user_id = ${req.userId}`;
        return { success: true };
    }
);

export const readAll = api(
    { expose: true, method: "POST", path: "/notifications/read-all" },
    async (req: UserRequest): Promise<SuccessResponse> => {
        await db.exec`UPDATE notifications SET is_read = TRUE WHERE user_id = ${req.userId}`;
        return { success: true };
    }
);

export const unreadCount = api(
    { expose: true, method: "POST", path: "/notifications/unread-count" },
    async (req: UserRequest): Promise<UnreadCountResponse> => {
        const result = await db.queryRow`SELECT COUNT(*) as count FROM notifications WHERE user_id = ${req.userId} AND is_read = FALSE`;
        return { count: parseInt(result?.count || "0") };
    }
);

export const getPreferences = api(
    { expose: true, method: "POST", path: "/notifications/preferences" },
    async (req: UserRequest): Promise<Preferences> => {
        const result = await db.queryRow`SELECT booking_updates, promotions, system_updates FROM notification_preferences WHERE user_id = ${req.userId}`;
        if (result) {
            return {
                booking_updates: result.booking_updates,
                promotions: result.promotions,
                system_updates: result.system_updates
            };
        }
        return { booking_updates: true, promotions: true, system_updates: true };
    }
);

export const updatePreferences = api(
    { expose: true, method: "PUT", path: "/notifications/preferences" },
    async (req: UserRequest & Preferences): Promise<SuccessResponse> => {
        await db.exec`
            INSERT INTO notification_preferences (user_id, booking_updates, promotions, system_updates)
            VALUES (${req.userId}, ${req.booking_updates}, ${req.promotions}, ${req.system_updates})
            ON CONFLICT (user_id) DO UPDATE SET 
                booking_updates = EXCLUDED.booking_updates,
                promotions = EXCLUDED.promotions,
                system_updates = EXCLUDED.system_updates
        `;
        await logActivity(req.userId, 'UPDATE_PREFERENCES', 'User updated notification preferences');
        return { success: true };
    }
);
