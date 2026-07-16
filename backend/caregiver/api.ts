import { api } from "encore.dev/api";
import { db } from "../db/db";

export interface BookingRequest {
    userId: number;
    providerId: number;
}

export interface BookingResponse {
    bookingId: number;
    status: string;
}

export const book = api(
    { expose: true, method: "POST", path: "/caregiver/book" },
    async (req: BookingRequest): Promise<BookingResponse> => {
        const user = await db.queryRow`SELECT id FROM users WHERE id = ${req.userId}`;
        if (!user) throw new Error("User tidak ditemukan");

        const booking = await db.queryRow`
            INSERT INTO bookings (user_id, provider_id, status)
            VALUES (${req.userId}, ${req.providerId}, 'pending')
            RETURNING id, status
        `;

        if (!booking) throw new Error("Gagal membuat booking caregiver");
        
        await db.exec`
            INSERT INTO activity_logs (user_id, user_name, user_role, action, detail)
            SELECT id, name, role, 'CAREGIVER_BOOK', 'User booked a caregiver' FROM users WHERE id = ${req.userId}
        `;

        return {
            bookingId: booking.id,
            status: booking.status
        };
    }
);
