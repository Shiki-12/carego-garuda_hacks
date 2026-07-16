# API Contract — CareGo Healthcare Platform

> **This is the single source of truth** for all backend API endpoints.  
> Dev A (Backend) updates this document. Dev B (Flutter/Web) reads and implements against it.  
> Last updated: 2026-07-16

**Base URLs:**
- Local: `http://localhost:4000`
- Staging: *(to be configured after Encore Cloud setup)*
- Flutter Emulator: `http://10.0.2.2:4000`

---

## Status Legend

| Status | Meaning |
|--------|---------|
| 🟢 Implemented | Endpoint is live and tested |
| 🟡 In Progress | Dev A is actively building |
| 🔴 Not Started | Planned but not yet built |
| ⚪ Stub | Endpoint exists but has minimal logic |

---

## Auth Service (`/auth/*`)

### POST `/auth/register` 🔴
Direct registration without OTP.

**Request:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string"
}
```

**Response (200):**
```json
{
  "token": "string (64 chars)",
  "user": {
    "id": 1,
    "name": "string",
    "email": "string",
    "role": "patient",
    "phone": "string | null",
    "photo_url": "string | null"
  }
}
```

**Errors:** `Email sudah terdaftar`, `Gagal membuat akun`

---

### POST `/auth/register-send-otp` 🔴
Step 1 of OTP registration: validates constraints and sends OTP.

**Request:**
```json
{
  "email": "string",
  "phone": "string",
  "method": "email | whatsapp"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP pendaftaran telah dikirim via whatsapp"
}
```

**Errors:** `Email sudah terdaftar`, `Nomor WhatsApp sudah terdaftar`

---

### POST `/auth/register-verify-otp` 🔴
Step 2 of OTP registration: verifies OTP and creates account.

**Request:**
```json
{
  "name": "string",
  "email": "string",
  "phone": "string",
  "password": "string",
  "code": "string (6 digits)"
}
```

**Response (200):** Same as `/auth/register`

**Errors:** `Kode OTP salah atau sudah kedaluwarsa`, `Email sudah terdaftar`

---

### POST `/auth/login` 🔴
Login with email and password.

**Request:**
```json
{
  "email": "string",
  "password": "string"
}
```

**Response (200):** Same as `/auth/register`

**Errors:** `Email tidak ditemukan`, `Password salah`

---

### POST `/auth/send-otp` 🔴
Send OTP for passwordless login.

**Request:**
```json
{
  "identifier": "string (email or phone)",
  "method": "email | whatsapp"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "OTP telah dikirim via whatsapp"
}
```

---

### POST `/auth/verify-otp` 🔴
Verify OTP for login. Auto-creates account if user doesn't exist.

**Request:**
```json
{
  "identifier": "string (email or phone)",
  "code": "string (6 digits)"
}
```

**Response (200):** Same as `/auth/register`

**Errors:** `Kode OTP salah atau sudah kedaluwarsa`

---

### POST `/auth/google` 🔴
Google OAuth login. Auto-creates account if user doesn't exist.

**Request:**
```json
{
  "googleId": "string",
  "email": "string",
  "name": "string"
}
```

**Response (200):** Same as `/auth/register`

---

### POST `/auth/me` 🔴
Validate session token and return user info.

**Request:**
```json
{
  "token": "string"
}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "string",
  "email": "string",
  "role": "string",
  "phone": "string | null",
  "photo_url": "string | null"
}
```

**Errors:** `Session tidak valid atau sudah expired`

---

### POST `/auth/logout` 🔴
Delete session and log activity.

**Request:**
```json
{
  "token": "string"
}
```

**Response (200):**
```json
{
  "success": true
}
```

---

## User Service (`/user/*`)

### POST `/user/balance` 🔴
Get wallet balance for a user.

**Request:**
```json
{
  "userId": 1
}
```

**Response (200):**
```json
{
  "balance": 250000
}
```

---

### POST `/user/profile/update` 🔴
Update phone number and/or profile photo.

**Request:**
```json
{
  "userId": 1,
  "phone": "08123456789 (optional)",
  "photoBase64": "data:image/... (optional)"
}
```

**Response (200):**
```json
{
  "success": true
}
```

---

## Ambulance Service (`/ambulance/*`)

### POST `/ambulance/book` 🔴
Create an ambulance booking.

**Request:**
```json
{
  "userId": 1,
  "providerId": 1
}
```

**Response (200):**
```json
{
  "bookingId": 1,
  "status": "pending"
}
```

---

### GET `/ambulance/recommendations` 🔴
Get active recommendations for home screen display.

**Response (200):**
```json
{
  "recommendations": [
    {
      "id": "1",
      "title": "Ambulance BLS",
      "tagLabel": "Tersedia 24 Jam",
      "tagColor": "bg-teal-600",
      "rating": 4.9,
      "reviews": 120,
      "price": "Mulai Rp 350.000",
      "image": "https://..."
    }
  ]
}
```

---

## Admin Service (`/admin/*`)

### POST `/admin/recommendations` 🔴
Create a new recommendation.

**Request:**
```json
{
  "serviceType": "ambulance",
  "title": "string",
  "tagLabel": "string",
  "tagColor": "bg-teal-600",
  "price": "string",
  "image": "https://...",
  "adminUserId": 1
}
```

**Response (200):** Recommendation object

---

### DELETE `/admin/recommendations/:id` 🔴
Delete a recommendation by ID.

**Response (200):**
```json
{
  "success": true
}
```

---

### POST `/admin/users` 🔴
Create a new user (admin-only).

**Request:**
```json
{
  "name": "string",
  "email": "string",
  "password": "string",
  "role": "doctor | caregiver | ambulance | customer_service | admin",
  "adminUserId": 1
}
```

**Response (200):**
```json
{
  "id": 1,
  "name": "string",
  "email": "string",
  "role": "string",
  "createdAt": "string"
}
```

---

### GET `/admin/users` 🔴
List all users.

**Response (200):**
```json
{
  "users": [
    {
      "id": 1,
      "name": "string",
      "email": "string",
      "role": "string",
      "createdAt": "string"
    }
  ]
}
```

---

### GET `/admin/activity-logs` 🔴
Get the latest 100 activity log entries.

**Response (200):**
```json
{
  "logs": [
    {
      "id": 1,
      "userName": "string",
      "userRole": "string",
      "action": "LOGIN",
      "detail": "string",
      "createdAt": "string"
    }
  ]
}
```

---

## Caregiver Service (`/caregiver/*`)

### POST `/caregiver/book` 🔴
Book a caregiver (stub).

**Request/Response:** Same as `/ambulance/book`

---

## Rental Service (`/rental/*`)

### POST `/rental/book` 🔴
Book medical equipment rental (stub).

**Request/Response:** Same as `/ambulance/book`

---

## App Service (`/app/*`)

### GET `/app/version` 🔴
Check latest app version for auto-update.

**Response (200):**
```json
{
  "latestVersion": "1.0.0",
  "downloadUrl": "https://github.com/Shiki-12/carego-garuda_hacks/releases/latest/download/carego-release.apk",
  "releaseNotes": "Versi pertama CAREGO",
  "forceUpdate": false
}
```

---

## Changelog

| Date | Change | Author |
|------|--------|--------|
| 2026-07-16 | Initial contract created from prototype docs | — |
