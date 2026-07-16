# Developer Assignments — CareGo Healthcare Platform

> **Status:** Menuju Milestone 2 (Pengembangan Fitur Inti)
> **Branch saat ini:** `develop`

---

## 👨‍💻 Developer A (Seluruh Backend + Frontend Pasien)
**Tanggung Jawab:** Mengerjakan **Seluruh Backend API** (untuk semua fitur) DAN Frontend Flutter khusus untuk bagian Pasien.

### Tugas Saat Ini (Milestone 2 - Patient Scope & API):
1. **Seluruh Backend Services (`backend/`)**
   - Mengembangkan API untuk User, Ambulance, Admin, Caregiver, dll.
   - Mengurus migrasi database dan struktur data.
3. **Frontend: Aplikasi Flutter (Pasien)**
   - Desain dan implementasi UI `login_screen.dart` & `register_screen.dart`.
   - Menghubungkan form login ke `ApiService.login()`.
   - Desain UI `home_screen.dart` (Dashboard utama pasien).
   - Menambahkan metode ke `ApiService` untuk User & Ambulance.

---

## 👨‍💻 Developer B (Frontend Mitra: Dokter/Perawat & Admin)
**Tanggung Jawab:** Membangun antarmuka pengguna (Frontend) untuk Tenaga Medis (Aplikasi Mitra) dan Dashboard Admin Web. Backend-nya akan disediakan oleh Developer A.

### Tugas Saat Ini (Milestone 2 - Provider Scope):
1. **Frontend: Admin Web (`admin-frontend/`)**
   - Inisialisasi Vite + React untuk Dashboard Admin.
   - Integrasi login admin dengan backend API yang dibuat Dev A.
2. **Frontend: Aplikasi Mitra (Flutter)**
   - Mulai mendesain UI untuk penerimaan order ambulans/perawat.

---

## 🤝 Aturan Kolaborasi (Workflow)
1. **Gaya Baru (Vertical Slice):** Pembagian kini tidak lagi dibelah antara Backend dan Frontend, melainkan **Berdasarkan Fitur**.
2. **Hati-hati pada folder bersama:** File seperti `api_service.dart`, `pubspec.yaml`, dan folder `migrations/` akan disentuh oleh berdua. Lakukan `git pull` setiap hari agar meminimalisir *conflict*.
3. **Branching:**
   - Dev A menggunakan branch: `feature/patient-[nama-fitur]`
   - Dev B menggunakan branch: `feature/provider-[nama-fitur]`
