import { api } from "encore.dev/api";
import { db } from "../db/db";
import { logActivity } from "../utils/logger";

export interface BookingRequest {
    userId: number;
    providerId: number;
}

export interface BookingResponse {
    bookingId: number;
    status: string;
}

export const book = api(
    { expose: true, method: "POST", path: "/rental/book" },
    async (req: BookingRequest): Promise<BookingResponse> => {
        const user = await db.queryRow`SELECT id FROM users WHERE id = ${req.userId}`;
        if (!user) throw new Error("User tidak ditemukan");

        const booking = await db.queryRow`
            INSERT INTO bookings (user_id, provider_id, status)
            VALUES (${req.userId}, ${req.providerId}, 'pending')
            RETURNING id, status
        `;

        if (!booking) throw new Error("Gagal membuat booking rental alat medis");
        
        await logActivity(req.userId, 'RENTAL_BOOK', 'User booked medical equipment');

        return {
            bookingId: booking.id,
            status: booking.status
        };
    }
);
