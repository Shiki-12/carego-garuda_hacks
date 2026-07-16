# Developer Assignments — CareGo Healthcare Platform

> **Status:** Menuju Milestone 2 (Pengembangan Fitur Inti)
> **Branch saat ini:** `develop`

---

## 👨‍💻 Developer A (Fokus Pasien)
**Tanggung Jawab:** Mengerjakan *Fullstack* (Backend + Frontend) untuk semua fitur yang digunakan oleh Pasien.

### Tugas Saat Ini (Milestone 2 - Patient Scope):
1. **Backend: User Service (`backend/user/`)**
   - `POST /user/balance` (Cek saldo)
   - `POST /user/profile/update` (Update data profil)
2. **Backend: Ambulance Service (`backend/ambulance/`)**
   - `GET /ambulance/recommendations`
   - `POST /ambulance/book`
3. **Frontend: Aplikasi Flutter (Pasien)**
   - Desain dan implementasi UI `login_screen.dart` & `register_screen.dart`.
   - Menghubungkan form login ke `ApiService.login()`.
   - Desain UI `home_screen.dart` (Dashboard utama pasien).
   - Menambahkan metode ke `ApiService` untuk User & Ambulance.

---

## 👨‍💻 Developer B (Fokus Mitra: Dokter/Perawat & Admin)
**Tanggung Jawab:** Mengerjakan *Fullstack* (Backend + Frontend) untuk semua fitur yang digunakan oleh Tenaga Medis (Dokter/Perawat) dan Admin Rumah Sakit.

### Tugas Saat Ini (Milestone 2 - Provider Scope):
1. **Backend: Caregiver Service (`backend/caregiver/`)**
   - Mendesain endpoint untuk list dokter/perawat yang tersedia.
   - Endpoint booking/jadwal konsultasi.
2. **Backend: Admin Service (`backend/admin/`)**
   - `GET /admin/users`
   - CRUD untuk rekomendasi layanan.
3. **Frontend: Admin Web (`admin-frontend/`)**
   - Inisialisasi Vite + React untuk Dashboard Admin.
   - Integrasi login admin dengan backend.

---

## 🤝 Aturan Kolaborasi (Workflow)
1. **Gaya Baru (Vertical Slice):** Pembagian kini tidak lagi dibelah antara Backend dan Frontend, melainkan **Berdasarkan Fitur**.
2. **Hati-hati pada folder bersama:** File seperti `api_service.dart`, `pubspec.yaml`, dan folder `migrations/` akan disentuh oleh berdua. Lakukan `git pull` setiap hari agar meminimalisir *conflict*.
3. **Branching:**
   - Dev A menggunakan branch: `feature/patient-[nama-fitur]`
   - Dev B menggunakan branch: `feature/provider-[nama-fitur]`
