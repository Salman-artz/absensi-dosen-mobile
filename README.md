# 🎓 Absensi Dosen & Mahasiswa — Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Riverpod-2.x-1B365D)](https://riverpod.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Feature--First%20Clean%20Arch-success)](#-arsitektur-aplikasi-clean-architecture)
[![UI Theme](https://img.shields.io/badge/Theme-Nordic%20Electric%20Indigo-6366F1)](#-design-system-nordic-electric-indigo)
[![E2E Testing](https://img.shields.io/badge/E2E%20Tested-Playwright%20MCP-45ba4b?logo=playwright&logoColor=white)](#-pengujian-end-to-end-playwright-mcp)
[![Backend Repository](https://img.shields.io/badge/Backend-absensi--dosen--backend-22c55e?logo=github)](https://github.com/Salman-artz/absensi-dosen-backend)

Aplikasi mobile berbasis **Flutter** untuk sistem manajemen kehadiran akademik perguruan tinggi, menghubungkan dosen pengampu dan program studi dalam tata kelola presensi berbasis QR Code, pencatatan kehadiran pertemuan mahasiswa secara cepat (1-Click Bulk Attendance), ekspor rekapitulasi multi-format (PDF & Excel), serta pelaporan izin/dinas luar terintegrasi.

Dibangun dengan pendekatan **Feature-First Clean Architecture**, antarmuka modern **Nordic Electric Indigo**, serta pengujian otomatis alur interaktif berbasis **Playwright MCP**.

---

## 📸 Dokumentasi Antarmuka (Showcase Portofolio)

### 1. Autentikasi, Dasbor Jadwal Mengajar & Ekspor Rekapitulasi

<p align="center">
  <img src="screenshots/porto_01_login_screen.png" alt="Login Screen" width="22%" />
  &nbsp;
  <img src="screenshots/porto_02_dosen_jadwal_light.png" alt="Jadwal Dosen Light" width="22%" />
  &nbsp;
  <img src="screenshots/porto_03_dosen_jadwal_dark.png" alt="Jadwal Dosen Dark" width="22%" />
  &nbsp;
  <img src="screenshots/porto_04_ekspor_modal.png" alt="Ekspor Rekap Modal" width="22%" />
</p>
<p align="center">
  <em>(1) Autentikasi Nordic SaaS Minimalist &nbsp;|&nbsp; (2) Jadwal Dosen (Mode Terang) &nbsp;|&nbsp; (3) Jadwal Dosen (Mode Gelap) &nbsp;|&nbsp; (4) Ekspor Rekap PDF & Excel</em>
</p>

### 2. Alur Presensi Mahasiswa, 1-Click Bulk Attendance & Layanan Dosen

<p align="center">
  <img src="screenshots/porto_05_presensi_selection.png" alt="Pemilihan Jadwal & Pertemuan" width="22%" />
  &nbsp;
  <img src="screenshots/porto_06_presensi_pertemuan_flow.png" alt="1-Click Presensi Pertemuan" width="22%" />
  &nbsp;
  <img src="screenshots/porto_07_dosen_izin.png" alt="Riwayat Izin & Tugas Luar" width="22%" />
  &nbsp;
  <img src="screenshots/porto_08_dosen_notifikasi.png" alt="Pusat Notifikasi Akademik" width="22%" />
</p>
<p align="center">
  <em>(5) Pemilihan Kelas & Pertemuan 1-16 &nbsp;|&nbsp; (6) 1-Click "Tandai Semua Hadir" & Status Pills &nbsp;|&nbsp; (7) Pengajuan Izin/Dinas Luar &nbsp;|&nbsp; (8) Notifikasi Akademik</em>
</p>

### 3. Dasbor Administrator Prodi & Tata Kelola Kelas Mahasiswa

<p align="center">
  <img src="screenshots/porto_09_admin_dashboard.png" alt="Dasbor Admin" width="22%" />
  &nbsp;
  <img src="screenshots/porto_10_admin_student_classes.png" alt="Grup Kelas Mahasiswa" width="22%" />
  &nbsp;
  <img src="screenshots/porto_11_admin_student_roster.png" alt="Roster Mahasiswa TI-3A" width="22%" />
  &nbsp;
  <img src="screenshots/porto_12_admin_schedule_management.png" alt="Manajemen Jadwal Institusi" width="22%" />
</p>
<p align="center">
  <em>(9) Metrik Dasbor Global & Per Dosen &nbsp;|&nbsp; (10) Grup Kelas & Import &nbsp;|&nbsp; (11) Roster Mahasiswa Lengkap NIM &nbsp;|&nbsp; (12) Tata Kelola Master Jadwal</em>
</p>

---

## ✨ Fitur Unggulan

### 🧑‍🏫 Portal Dosen (Lecturer Portal)
- **Nordic Indigo Theme**: Dukungan penuh **Light Mode** & **Dark Mode** yang persisten via SharedPreferences.
- **Kartu Jadwal Mengajar Terintegrasi**: Informasi mata kuliah, kelas, SKS, ruangan, dan jam ajar terorganisir per hari.
- **1-Click Bulk Attendance ("Tandai Semua Hadir")**:
  - Tombol cepat untuk menandai seluruh mahasiswa dalam kelas sebagai **Hadir (H)** dalam satu kali ketuk.
  - Live counter metrics ter-update secara instan (*Hadir, Sakit, Izin, Alpa*).
  - Segmented status pill individual untuk koreksi manual cepat jika ada mahasiswa sakit/izin.
- **Ekspor Rekap Langsung di Perangkat**:
  - **Laporan PDF**: Format resmi siap cetak untuk pengarsipan akademik.
  - **Spreadsheet Excel (.xlsx)**: Format tabular untuk rekap nilai & analisis data.
- **Presensi Dosen QR Code**: Scan QR kode dinamis dengan batas waktu toleransi keterlambatan.
- **Pengajuan Izin & Dinas Luar**: Pelacakan status permohonan (*Pending, Approved, Rejected*).
- **Pusat Notifikasi**: Pengumuman kalender akademik dan pengingat batas pengisian presensi mingguan.

### 🏛️ Portal Administrator & Akademik (Admin Portal)
- **Dasbor Metrik Institusi**: Rekapitulasi kehadiran global serta monitoring performa presensi tiap dosen pengampu.
- **Manajemen Jadwal Perkuliahan**: Pembuatan jadwal, penugasan dosen, pengaturan sesi QR, dan ekspor berkas.
- **Tata Kelola Mahasiswa & Grup Kelas**: Visualisasi jumlah mahasiswa per rombongan belajar, import massal via Excel, serta manajemen data siswa.
- **Approval Pengajuan Izin**: Verifikasi dan validasi izin atau tugas luar kota yang diajukan staf pengajar.

---

## 🏗 Arsitektur Aplikasi (Clean Architecture)

Aplikasi mengadopsi pola **Feature-First Clean Architecture** untuk memastikan decoupling, keterbacaan kode, dan kemudahan testing:

```text
lib/
├── core/
│   ├── api/             # Dio client, JWT interceptor, refresh token handler
│   ├── router/          # GoRouter configuration & role-based route guards
│   ├── theme/           # Nordic Indigo design system (AppColors, AppTheme, ThemeProvider)
│   ├── utils/           # ReportExporter (PDFKit & Syncfusion Excel engines)
│   └── widgets/         # Adaptive home shell (DosenHomeShell & AdminHomeShell)
└── features/
    ├── auth/            # domain (AuthUser), data (AuthRepo), presentation (LoginScreen, AuthProvider)
    ├── attendance/      # domain, data, presentation (ScanAbsenScreen, GenerateQrScreen)
    ├── dashboard/       # domain, data, presentation (AdminDashboardScreen, DashboardProvider)
    ├── leave/           # domain, data, presentation (DosenLeaveScreen, AdminLeaveScreen)
    ├── master_data/     # domain, data, presentation (AdminMasterScreen)
    ├── meeting/         # domain, data, presentation (MeetingAttendanceScreen, PresensiDosenScreen)
    ├── notification/    # domain, data, presentation (NotificationScreen, NotificationProvider)
    ├── schedule/        # domain, data, presentation (DosenScheduleScreen, AdminScheduleScreen)
    └── student/         # domain, data, presentation (AdminStudentScreen, StudentClassDetailScreen)
```

Tiap fitur dipisahkan secara tegas ke dalam 3 layer utama:
1. **Domain Layer**: Berisi entitas model bisnis murni (`models/`) dan kontrak antarmuka repositori (`repositories/`). Bebas dari dependensi UI maupun framework eksternal.
2. **Data Layer**: Berisi implementasi repositori (`repositories_impl/`) yang berkomunikasi dengan API backend menggunakan Dio.
3. **Presentation Layer**: Berisi state notifier (`providers/`), layar antarmuka (`screens/`), dan komponen UI reaktif (`widgets/`).

---

## 🎨 Design System: Nordic Electric Indigo

Aplikasi menggunakan palet desain bertema **Nordic Electric Indigo** yang memberikan nuansa profesional, bersih, dan modern:

| Elemen Desain | Light Mode | Dark Mode | Fungsi |
| :--- | :---: | :---: | :--- |
| **Primary** | `#4F46E5` (Electric Indigo) | `#6366F1` (Indigo Bright) | Brand accent, button utama, active indicator |
| **Primary Dark** | `#3730A3` | `#4338CA` | Header gradient & appbar background |
| **Background** | `#F8FAFC` (Nordic White) | `#0B0F19` (Deep Obsidian) | Scaffold canvas background |
| **Surface Card** | `#FFFFFF` (Pure White) | `#111827` (Nordic Slate) | Kartu jadwal, modal, floating navbar |
| **Border** | `#E2E8F0` | `#1F2937` | Pembatas kontras elemen & segmented pills |
| **Accent Pill** | `#10B981` (Hadir) &nbsp; `#F59E0B` (Izin) &nbsp; `#3B82F6` (Sakit) &nbsp; `#EF4444` (Alpa) | Indikator status kehadiran reaktif |

---

## 🧪 Pengujian End-to-End (Playwright MCP)

Seluruh alur interaksi aplikasi telah diverifikasi secara live menggunakan **Playwright MCP** di Flutter Web Server (`Chrome` viewport 412x900):

- [x] **Light/Dark Toggle**: Pengujian peralihan tema instan pada layar Login dan Dasbor.
- [x] **Autentikasi Dua Role**: Validasi sesi JWT untuk akun Dosen (`dosen@kampus.ac.id`) dan Admin (`admin@kampus.ac.id`).
- [x] **Ekspor Rekap**: Verifikasi pemanggilan bottom sheet dan generasi berkas PDF/Excel.
- [x] **1-Click Bulk Attendance**: Penandaan massal 12 mahasiswa menjadi Hadir dan reaktifitas live counter (*Hadir: 10, Sakit: 1, Izin: 1*).
- [x] **Navigasi GoRouter Guard**: Redirect otomatis berdasarkan role dan proteksi route private.

Laporan pengujian lengkap dapat dilihat di [test_flow_report.md](file:///C:/Users/salma/.gemini/antigravity-cli/brain/c7de59d0-8e8a-436c-97e6-735d451de97c/test_flow_report.md).

---

## 💻 Tech Stack

- **Framework**: [Flutter 3.x](https://flutter.dev) (Dart SDK 3.5+)
- **State Management**: [Riverpod 2.x](https://riverpod.dev)
- **Routing & Navigation**: [GoRouter 14.x](https://pub.dev/packages/go_router)
- **Networking**: [Dio 5.x](https://pub.dev/packages/dio) with JWT Bearer Interceptors & Auto Refresh Token
- **Storage**: [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage) & [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **Document Exporting**: [PDF](https://pub.dev/packages/pdf), [Printing](https://pub.dev/packages/printing), [Syncfusion Flutter XlsIO](https://pub.dev/packages/syncfusion_flutter_xlsio), [Open File](https://pub.dev/packages/open_file)
- **QR Code Engine**: [Mobile Scanner](https://pub.dev/packages/mobile_scanner) & [QR Flutter](https://pub.dev/packages/qr_flutter)

---

## 🚀 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- Flutter SDK (versi 3.22+ / Dart 3.5+)
- Backend Absensi Dosen aktif berjalan di port 4000 ([panduan backend](https://github.com/Salman-artz/absensi-dosen-backend))

### 2. Instalasi Dependency
```bash
flutter pub get
```

### 3. Menjalankan Aplikasi

**A. Mode Web (Google Chrome):**
```bash
flutter run -d chrome
```

**B. Mode Android Emulator:**
```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4000/api
```

**C. Mode Device Fisik (Wi-Fi LAN yang Sama):**
```bash
flutter run --dart-define=API_BASE_URL=http://IP-KOMPUTER-ANDA:4000/api
```

### 4. Kredensial Uji Coba (Seed Data)
| Role | Email | Password | Hak Akses |
| :--- | :--- | :--- | :--- |
| **Dosen** | `dosen@kampus.ac.id` | `password123` | Jadwal, 1-Click Presensi, Izin, Ekspor Rekap |
| **Admin** | `admin@kampus.ac.id` | `password123` | Dasbor Global, Grup Mahasiswa, Master Jadwal |

---

## 📦 Build Produksi

Android APK:
```bash
flutter build apk --release --dart-define=API_BASE_URL=https://api.domain-kampus.ac.id/api
```

Flutter Web:
```bash
flutter build web --release --dart-define=API_BASE_URL=https://api.domain-kampus.ac.id/api
```

---

## 🔒 Catatan Keamanan & Best Practices
- **Token Storage**: Akses token JWT disimpan secara terenkripsi menggunakan Keystore/Keychain melalui Flutter Secure Storage.
- **Documentation Integrity**: Semua logika bisnis terisolasi pada layer domain dan terlindungi dari kebocoran implementasi UI.
- **Analyzer Compliance**: Lulus audit static code analysis dengan `flutter analyze` (0 warnings, 0 issues).
