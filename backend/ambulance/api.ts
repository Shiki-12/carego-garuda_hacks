import { api } from "encore.dev/api";
import { db } from "../db/db";

export interface Recommendation {
    id: number;
    title: string;
    description: string;
    image_url: string | null;
    service_type: string;
    action_url: string;
    is_active: boolean;
}

export interface RecommendationsResponse {
    data: Recommendation[];
}

export interface BookingRequest {
    userId: number;
    providerId: number;
}

export interface BookingResponse {
    bookingId: number;
    status: string;
}

export interface WsResponse {
    success: boolean;
    message: string;
}

export const recommendations = api(
    { expose: true, method: "GET", path: "/ambulance/recommendations" },
    async (): Promise<RecommendationsResponse> => {
        const result = await db.query`
            SELECT id, title, description, image_url, service_type, action_url, is_active 
            FROM recommendations 
            WHERE is_active = TRUE
            ORDER BY created_at DESC
        `;
        
        const recs: Recommendation[] = [];
        for await (const row of result) {
            recs.push({
                id: row.id,
                title: row.title,
                description: row.description,
                image_url: row.image_url,
                service_type: row.service_type,
                action_url: row.action_url,
                is_active: row.is_active
            });
        }
        
        return { data: recs };
    }
);

export const book = api(
    { expose: true, method: "POST", path: "/ambulance/book" },
    async (req: BookingRequest): Promise<BookingResponse> => {
        const user = await db.queryRow`SELECT id FROM users WHERE id = ${req.userId}`;
        if (!user) throw new Error("User tidak ditemukan");

        // The exact price and coords are missing in schema, so we insert basic data per schema
        const booking = await db.queryRow`
            INSERT INTO bookings (patient_id, caregiver_id, status)
            VALUES (${req.userId}, ${req.providerId}, 'pending')
            RETURNING id, status
        `;

        if (!booking) throw new Error("Gagal membuat booking");
        
        await db.exec`
            INSERT INTO activity_logs (user_id, user_name, user_role, action, detail)
            SELECT id, name, role, 'AMBULANCE_BOOK', 'User booked ambulance' FROM users WHERE id = ${req.userId}
        `;

        return {
            bookingId: booking.id,
            status: booking.status
        };
    }
);

export const ws = api(
    { expose: true, method: "GET", path: "/ambulance/ws" },
    async (): Promise<WsResponse> => {
        return { success: true, message: "WebSocket stub for live tracking" };
    }
);
