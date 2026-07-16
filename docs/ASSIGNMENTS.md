# Developer Assignments — CareGo Healthcare Platform

> **Status:** Menuju Milestone 2 (User, Ambulance, & Admin Backend Services)
> **Branch saat ini:** `develop`

---

## 👨‍💻 Developer A (Backend & Infrastructure)
**Fokus Utama:** Mengembangkan REST API, logika bisnis, dan struktur database menggunakan Encore.ts.

### Tugas Saat Ini (Milestone 2):
1. **User Service (`backend/user/`)**
   - Implementasi endpoint `POST /user/balance` untuk mengambil saldo wallet.
   - Implementasi endpoint `POST /user/profile/update` untuk update nomor HP dan foto profil.
2. **Ambulance Service (`backend/ambulance/`)**
   - Implementasi endpoint `POST /ambulance/book` (memasukkan data booking ke tabel `bookings`).
   - Implementasi endpoint `GET /ambulance/recommendations` (mengambil data dari tabel `recommendations`).
3. **Admin Service (`backend/admin/`)**
   - Implementasi endpoint CRUD untuk `users` dan `recommendations`.
   - Implementasi endpoint `GET /admin/activity-logs`.
4. **Database & API Contract**
   - Memastikan semua endpoint berjalan sesuai spesifikasi di `docs/API_CONTRACT.md`.
   - Jika ada perubahan skema database, membuat file migrasi baru (misal: `9_add_new_feature.up.sql`).

---

## 👨‍💻 Developer B (Frontend / Mobile App)
**Fokus Utama:** Membangun antarmuka pengguna (UI) Flutter, state management, dan integrasi dengan API backend.

### Tugas Saat Ini (Milestone 2):
1. **Setup & Routing (`flutter-app/lib/`)**
   - Membuat struktur navigasi utama (Bottom Navigation Bar) untuk berpindah antar tab (Home, Orders, Book, Chat, Account).
2. **Authentication Screens (`flutter-app/lib/screens/`)**
   - Implementasi UI `login_screen.dart` (Email, Password, tombol Google Login).
   - Implementasi UI `register_screen.dart` (Form pendaftaran).
   - Menghubungkan form login/register dengan `ApiService.login()` dan logika AuthGate di `main.dart`.
3. **Home Dashboard UI (`flutter-app/lib/screens/home_screen.dart`)**
   - Membangun layout grid untuk pilihan layanan utama (Ambulance, Caregiver, Rental).
   - Membuat komponen UI untuk menampilkan data dummy recommendations (sebelum endpoint siap).
4. **API Integration**
   - Mengembangkan `ApiService` di `flutter-app/lib/services/api_service.dart` agar siap menerima data dari endpoint User dan Ambulance yang sedang dibuat Developer A.

---

## 🤝 Aturan Kolaborasi (Workflow)
1. **Jangan bekerja di file yang sama:** Developer A HANYA menyentuh folder `backend/`, Developer B HANYA menyentuh folder `flutter-app/` (dan `admin-frontend/` nantinya).
2. **Pull sebelum mulai:** Selalu jalankan `git pull origin develop` sebelum mulai coding setiap hari.
3. **Branching:**
   - Dev A menggunakan branch: `feature/backend-[nama-fitur]`
   - Dev B menggunakan branch: `feature/flutter-[nama-fitur]`
4. **Testing Bersama:** Jika backend sudah di-push, Dev B melakukan pull dan menjalankan `encore run` di lokal komputernya agar aplikasi Flutter bisa terhubung ke backend lokal.
