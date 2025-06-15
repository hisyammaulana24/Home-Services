# Spesifikasi Kebutuhan Perangkat Lunak (SRS) - Aplikasi Home Services (Flutter Android - Single Tenant)

**Versi Dokumen:** 2.0
**Tanggal:** 27 Mei 2025
**Penulis:** [Muhammad Hisyam Maulana]

## 1. Pendahuluan

### 1.1. Tujuan Aplikasi
Aplikasi Home Services ini bertujuan untuk menyediakan platform mobile Android yang efisien bagi satu bisnis layanan kebersihan untuk mengelola operasionalnya dan bagi pelanggan untuk memesan layanan kebersihan rumah. Aplikasi ini akan dikembangkan menggunakan Flutter untuk frontend dan Appwrite sebagai backend, dengan arsitektur single-tenant.

### 1.2. Ruang Lingkup Produk
Versi MVP (Minimum Viable Product) ini akan mencakup fungsionalitas berikut untuk aplikasi mobile Android:
*   **Untuk Pelanggan:**
    *   Registrasi dan login.
    *   Melihat daftar layanan kebersihan yang ditawarkan.
    *   Memilih layanan, menentukan lokasi (input manual), serta memilih tanggal dan waktu layanan.
    *   Melakukan pemesanan dan pembayaran (metode terbatas, misal transfer bank manual).
    *   Melihat status pemesanan dan riwayat pemesanan.
    *   Mengelola profil dasar.
*   **Untuk Admin Bisnis (melalui aplikasi atau panel admin terpisah):**
    *   Mengelola daftar layanan yang ditawarkan.
    *   Mengelola pesanan yang masuk (konfirmasi pembayaran, update status).
    *   Mengelola data penyedia jasa/cleaner (dasar).

### 1.3. Definisi, Akronim, dan Singkatan
*   **SRS:** Software Requirements Specification
*   **MVP:** Minimum Viable Product
*   **User:** Pengguna aplikasi.
    *   **Customer:** Pelanggan yang memesan layanan kebersihan.
    *   **Admin:** Staf dari bisnis layanan kebersihan yang mengelola aplikasi dan operasional.
    *   **Cleaner/Penyedia Jasa:** Individu atau tim yang melakukan layanan kebersihan, dikelola oleh Admin.
*   **Flutter:** UI toolkit dari Google untuk membangun aplikasi native yang indah untuk mobile (fokus Android untuk proyek ini), web, dan desktop dari satu codebase.
*   **Appwrite:** Backend as a Service (BaaS) yang digunakan.
*   **Single-Tenant:** Arsitektur di mana satu instansi aplikasi dan database melayani satu organisasi/bisnis.
*   **SDK:** Software Development Kit.
*   **UI:** User Interface (Antarmuka Pengguna).
*   **UX:** User Experience (Pengalaman Pengguna).
*   **API:** Application Programming Interface.
*   **Android:** Sistem operasi mobile yang menjadi target utama pengembangan aplikasi ini.

## 2. Deskripsi Umum

### 2.1. Perspektif Produk
Aplikasi ini adalah produk mandiri yang akan diakses oleh pelanggan dan admin melalui aplikasi mobile Android yang dibangun dengan Flutter. Aplikasi akan berinteraksi dengan backend Appwrite untuk autentikasi, manajemen data (layanan, pesanan, pengguna, cleaner), dan proses bisnis lainnya. Semua data akan berada dalam satu Project Appwrite yang didedikasikan untuk bisnis layanan kebersihan ini (single-tenant).

### 2.2. Fungsi Produk (Fitur MVP)
Fungsi utama produk untuk pengguna (Customer dan Admin) adalah:
1.  **F01: Registrasi Pengguna (Customer):** Memungkinkan pelanggan baru membuat akun.
2.  **F02: Login Pengguna (Customer & Admin):** Memungkinkan pengguna terdaftar masuk ke akun mereka dengan peran yang sesuai.
3.  **F03: Manajemen Profil Pengguna (Customer):** Memungkinkan pelanggan melihat dan mengedit informasi dasar profil mereka.
4.  **F04: Penelusuran Layanan (Customer):** Menampilkan daftar layanan kebersihan yang ditawarkan.
5.  **F05: Pemesanan Layanan (Customer):** Memungkinkan pelanggan memilih layanan, menentukan alamat, tanggal, dan waktu.
6.  **F06: Proses Pembayaran (Customer):** Memfasilitasi pembayaran untuk layanan yang dipesan.
7.  **F07: Pelacakan Status Pesanan (Customer):** Memungkinkan pelanggan melihat status terkini dari pesanan mereka.
8.  **F08: Riwayat Pesanan (Customer):** Menampilkan daftar semua pesanan yang pernah dilakukan pelanggan.
9.  **F09 (Admin): Manajemen Layanan:** Admin dapat menambah, mengubah, menghapus layanan yang ditawarkan.
10. **F10 (Admin): Manajemen Pesanan:** Admin dapat melihat dan mengelola pesanan yang masuk (konfirmasi, update status).
11. **F11 (Admin): Manajemen Cleaner (Dasar):** Admin dapat mengelola daftar cleaner/penyedia jasa.

### 2.3. Karakteristik Pengguna
*   **Customer (Pelanggan):**
    *   Individu atau keluarga yang membutuhkan jasa kebersihan rumah.
    *   Memiliki smartphone **Android** untuk menginstall dan menggunakan aplikasi Flutter.
    *   Mampu melakukan navigasi dasar pada aplikasi mobile.
*   **Admin (Staf Bisnis):**
    *   Bertanggung jawab mengelola konten layanan, mengkonfirmasi pesanan, mengelola pembayaran (verifikasi), dan menugaskan cleaner.
    *   Akan menggunakan aplikasi Flutter dengan tampilan/fitur admin atau panel admin web terpisah yang terhubung ke Appwrite.
*   **Cleaner/Penyedia Jasa:**
    *   Untuk MVP, data mereka dikelola oleh Admin. Aplikasi khusus untuk cleaner mungkin menjadi pengembangan di masa depan.

### 2.4. Alur Pengguna Utama (Customer)
mermaid
sequenceDiagram
    participant User
    participant System

    User->>System: Mulai Aplikasi
    Android->>User: Punya Akun?
    alt Tidak
        User->>System: Registrasi
        User->>System: Login
    else Ya
        User->>System: Login
    end

    User->>System: Akses Dashboard/Beranda
    User->>System: Lihat Daftar Layanan
    User->>System: Pilih Layanan
    User->>System: Input Alamat & Jadwal
    System-->>User: Tampilkan Ringkasan Pesanan
    User->>System: Konfirmasi Pesanan
    User->>System: Lakukan Pembayaran (Transfer)
    User->>System: Upload Bukti Bayar

    loop Cek Status
        User->>System: Lihat Status Pesanan
        alt Layanan Selesai
            System-->>User: Tampilkan Status: Selesai
        else Belum Selesai
            System-->>User: Status Belum Selesai
        end
    end

    User->>System: Akses Halaman Profil
    User->>System: Lihat Riwayat Pesanan
    User->>System: Logout


### 2.5. Batasan Umum
*   Aplikasi frontend akan dikembangkan menggunakan **Flutter**, dengan fokus utama pada platform **Android** untuk MVP ini.
*   Arsitektur backend adalah **single-tenant** menggunakan satu Project Appwrite.
*   Metode pembayaran awal akan terbatas pada transfer bank manual dengan upload bukti bayar.
*   Integrasi peta untuk pemilihan lokasi akan ditunda pasca-MVP (input alamat manual).
*   Notifikasi push akan diimplementasikan secara dasar untuk update status pesanan di Android.
*   Rating dan ulasan belum akan diimplementasikan di MVP.
*   Admin akan mengelola cleaner secara manual di sistem; cleaner belum memiliki aplikasi sendiri.
*   Pengembangan dan pengujian versi iOS tidak termasuk dalam lingkup MVP ini karena keterbatasan lingkungan pengembangan.

### 2.6. Asumsi dan Ketergantungan
*   Ketersediaan layanan Appwrite sebagai backend.
*   Pengguna memiliki koneksi internet yang stabil di perangkat mobile Android mereka.
*   Admin akan melakukan verifikasi pembayaran manual dan update status pesanan secara tepat waktu.

### **2.7. Alur Program Aplikasi (Application Flow)**
Bagian ini menjelaskan interaksi antara Aplikasi Flutter (Android) dan Backend Appwrite.

#### *2.7.1 Alur Registrasi Pengguna (Customer)* 
mermaid
sequenceDiagram
    actor User
    participant FlutterApp as Frontend (Flutter)
    participant AppwriteSDK as Appwrite SDK
    participant AppwriteAuth as Appwrite Auth

    User->>FlutterApp: Isi form registrasi & Submit
    FlutterApp->>FlutterApp: Validasi form
    FlutterApp->>AppwriteSDK: account.create(email, pass, name)
    AppwriteSDK->>AppwriteAuth: Request create user
    AppwriteAuth->>AppwriteAuth: Validasi, Buat user, Hash pass
    AppwriteAuth-->>AppwriteSDK: Respons (User data / Error)
    AppwriteSDK-->>FlutterApp: Kembalikan respons
    alt Sukses
        FlutterApp->>FlutterApp: Simpan user state (misal via Provider/Bloc)
        FlutterApp->>User: Arahkan ke Login/Dashboard & Pesan sukses
    else Gagal
        FlutterApp->>User: Tampilkan pesan error
    end


#### *2.7.2. Alur Login Pengguna (Customer/Admin)*
mermaid
sequenceDiagram
    actor User
    participant FlutterApp as Frontend (Flutter)
    participant AppwriteSDK as Appwrite SDK
    participant AppwriteAuth as Appwrite Auth

    User->>FlutterApp: Isi form login & Submit
    FlutterApp->>AppwriteSDK: account.createEmailSession(email, pass)
    AppwriteSDK->>AppwriteAuth: Request create session
    AppwriteAuth->>AppwriteAuth: Verifikasi, Buat sesi
    AppwriteAuth-->>AppwriteSDK: Respons (Sesi & User data / Error)
    AppwriteSDK-->>FlutterApp: Kembalikan respons
    alt Sukses
        FlutterApp->>FlutterApp: Simpan sesi & user data (termasuk peran jika ada)
        FlutterApp->>FlutterApp: Cek peran pengguna (dari Appwrite User Prefs/Teams)
        alt Peran Admin
            FlutterApp->>User: Arahkan ke Dashboard Admin
        else Peran Customer
            FlutterApp->>User: Arahkan ke Dashboard Customer
        end
    else Gagal
        FlutterApp->>User: Tampilkan pesan error
    end


#### *2.7.3. Alur Pembuatan Pesanan oleh Customer*
mermaid
sequenceDiagram
    actor Customer
    participant FlutterApp as Frontend (Flutter)
    participant AppwriteSDK as Appwrite SDK
    participant AppwriteDB as Appwrite Databases

    Customer->>FlutterApp: Konfirmasi Pemesanan
    FlutterApp->>FlutterApp: Ambil userId (dari user login), data pesanan
    FlutterApp->>AppwriteSDK: databases.createDocument('DATABASE_ID', 'bookings', ID.unique(), dataPesanan)
    AppwriteSDK->>AppwriteDB: Request create doc (Koleksi 'bookings')
    AppwriteDB->>AppwriteDB: Verifikasi permission, Buat dokumen
    AppwriteDB-->>AppwriteSDK: Respons (Dokumen pesanan / Error)
    AppwriteSDK-->>FlutterApp: Kembalikan respons
    alt Sukses
        FlutterApp->>Customer: Arahkan ke Pembayaran & Pesan sukses
    else Gagal
        FlutterApp->>Customer: Tampilkan pesan error
    end

### *2.7.4. Alur Upload Bukti Pembayaran oleh Customer*
mermaid
sequenceDiagram
    actor Customer
    participant FlutterApp as Frontend (Flutter)
    participant AppwriteSDK as Appwrite SDK
    participant AppwriteStorage as Appwrite Storage
    participant AppwriteDB as Appwrite Databases

    Customer->>FlutterApp: Pilih file & Submit bukti bayar
    FlutterApp->>AppwriteSDK: storage.createFile('ID_BUCKET_BUKTI', file)
    AppwriteSDK->>AppwriteStorage: Request simpan file
    AppwriteStorage->>AppwriteStorage: Verifikasi permission, Simpan file
    AppwriteStorage-->>AppwriteSDK: Respons (File metadata / Error)
    AppwriteSDK-->>FlutterApp: Kembalikan respons upload
    alt Upload File Sukses
        FlutterApp->>FlutterApp: Get fileId/URL
        FlutterApp->>FlutterApp: Siapkan dataUpdate (proofUrl, paymentStatus)
        FlutterApp->>AppwriteSDK: databases.updateDocument('DATABASE_ID', 'bookings', bookingId, dataUpdate)
        AppwriteSDK->>AppwriteDB: Request update doc pesanan
        AppwriteDB->>AppwriteDB: Verifikasi, Update dokumen
        AppwriteDB-->>AppwriteSDK: Respons (Sukses / Gagal)
        AppwriteSDK-->>FlutterApp: Kembalikan respons update
        alt Update Dokumen Sukses
            FlutterApp->>Customer: Arahkan & Pesan sukses
        else Update Dokumen Gagal
            FlutterApp->>Customer: Tampilkan pesan error
        end
    else Upload File Gagal
        FlutterApp->>Customer: Tampilkan pesan error
    end


### *2.7.5. Alur Manajemen Layanan oleh Admin*
mermaid
sequenceDiagram
    actor Admin
    participant FlutterApp as Frontend (Flutter)
    participant AppwriteSDK as Appwrite SDK
    participant AppwriteDB as Appwrite Databases

    Admin->>FlutterApp: Isi form layanan & Submit
    FlutterApp->>FlutterApp: Validasi form & peran Admin
    FlutterApp->>FlutterApp: Siapkan dataLayanan
    alt Tambah Layanan
        FlutterApp->>AppwriteSDK: databases.createDocument('DATABASE_ID', 'services', ID.unique(), dataLayanan)
    else Edit Layanan
        FlutterApp->>AppwriteSDK: databases.updateDocument('DATABASE_ID', 'services', serviceId, dataLayanan)
    end
    AppwriteSDK->>AppwriteDB: Request C/U doc (Koleksi 'services')
    AppwriteDB->>AppwriteDB: Verifikasi permission (Admin), Create/Update dokumen
    AppwriteDB-->>AppwriteSDK: Respons (Dokumen layanan / Error)
    AppwriteSDK-->>FlutterApp: Kembalikan respons
    alt Sukses
        FlutterApp->>FlutterApp: Update UI daftar layanan
        FlutterApp->>Admin: Arahkan & Pesan sukses
    else Gagal
        FlutterApp->>Admin: Tampilkan pesan error
    end

## 3. Kebutuhan Spesifik (Fungsional)

Berikut adalah detail kebutuhan fungsional berdasarkan fitur MVP:

---

### 3.1. Modul Autentikasi Pengguna

#### 3.1.1. F01: Registrasi Pengguna (Customer)
*   **User Story (US01.1):** Sebagai *Calon Pelanggan*, saya ingin bisa *mendaftar menggunakan nama, email, dan kata sandi* agar saya bisa *membuat akun dan memesan layanan*.
*   **Kriteria Penerimaan (AC):**
    *   Formulir registrasi mencakup field: Nama, Email, Kata Sandi, Konfirmasi Kata Sandi.
    *   Validasi input untuk email (format valid, unik di sistem).
    *   Setelah berhasil, pengguna diarahkan ke halaman login atau langsung login.

#### 3.1.2. F02: Login Pengguna (Customer & Admin)
*   **User Story (US02.1):** Sebagai *Pengguna terdaftar (Customer/Admin)*, saya ingin bisa *login menggunakan email dan kata sandi saya* agar saya bisa *mengakses fitur sesuai peran saya*.
*   **User Story (US02.2):** Sistem harus bisa *membedakan antara Customer dan Admin* setelah login (misalnya, menggunakan Appwrite Teams atau atribut `role` di data pengguna) dan menampilkan UI yang sesuai.
*   **Kriteria Penerimaan (AC):**
    *   Setelah login berhasil, Customer diarahkan ke dashboard customer.
    *   Setelah login berhasil, Admin diarahkan ke dashboard admin (atau bagian admin di aplikasi).

---

### 3.2. Modul Manajemen Profil (Customer)

#### 3.2.1. F03: Manajemen Profil Pengguna (Customer)
*   **User Story (US03.1):** Sebagai *Customer*, saya ingin bisa *melihat informasi profil saya (nama, email, nomor telepon)*.
*   **User Story (US03.2):** Sebagai *Customer*, saya ingin bisa *mengubah nama dan nomor telepon saya*.
*   **User Story (US03.3):** Sebagai *Customer*, saya ingin bisa *logout dari akun saya*.
*   **Kriteria Penerimaan (AC):**
    *   Perubahan disimpan dengan benar ke backend Appwrite.

---

### 3.3. Modul Layanan dan Pemesanan (Customer)

#### 3.3.1. F04: Penelusuran Layanan (Customer)
*   **User Story (US04.1):** Sebagai *Customer*, saya ingin bisa *melihat daftar layanan kebersihan yang tersedia* beserta *deskripsi singkat dan harga*.
*   **Kriteria Penerimaan (AC):**
    *   Daftar layanan diambil dari koleksi `services` di Appwrite.

#### 3.3.2. F05: Pemesanan Layanan (Customer)
*   **User Story (US05.1):** Sebagai *Customer*, setelah *memilih layanan*, saya ingin bisa *memasukkan alamat lengkap layanan secara manual*.
*   **User Story (US05.2):** Sebagai *Customer*, saya ingin bisa *memilih tanggal dan slot waktu yang tersedia* untuk layanan.
*   **User Story (US05.3):** Sebagai *Customer*, saya ingin bisa *melihat ringkasan pesanan* sebelum konfirmasi.
*   **Kriteria Penerimaan (AC):**
    *   Pesanan baru tersimpan di koleksi `bookings` di Appwrite.

#### 3.3.3. F06: Proses Pembayaran (Customer)
*   **User Story (US06.1):** Sebagai *Customer*, setelah *mengkonfirmasi pesanan*, saya ingin *diinformasikan mengenai detail rekening bank tujuan dan jumlah yang harus dibayar*.
*   **User Story (US06.2):** Sebagai *Customer*, saya ingin bisa *mengunggah bukti transfer pembayaran*.
*   **Kriteria Penerimaan (AC):**
    *   Bukti transfer tersimpan di Appwrite Storage dan terasosiasi dengan pesanan.

#### 3.3.4. F07: Pelacakan Status Pesanan (Customer)
*   **User Story (US07.1):** Sebagai *Customer*, saya ingin bisa *melihat status terkini dari pesanan saya* (misalnya: Menunggu Pembayaran, Diproses, Selesai).
*   **Kriteria Penerimaan (AC):**
    *   Status pesanan diambil dari koleksi `bookings`.

#### 3.3.5. F08: Riwayat Pesanan (Customer)
*   **User Story (US08.1):** Sebagai *Customer*, saya ingin bisa *melihat daftar semua pesanan yang pernah saya buat*.
*   **Kriteria Penerimaan (AC):**
    *   Riwayat pesanan diambil dari koleksi `bookings`.

---

### 3.4. Modul Manajemen Admin

#### 3.4.1. F09 (Admin): Manajemen Layanan
*   **User Story (US09.1):** Sebagai *Admin*, saya ingin bisa *menambah, melihat, mengedit, dan menonaktifkan layanan* yang ditawarkan.
*   **Kriteria Penerimaan (AC):**
    *   Perubahan tersimpan di koleksi `services` Appwrite.
    *   Hanya Admin yang bisa mengakses fitur ini.

#### 3.4.2. F10 (Admin): Manajemen Pesanan
*   **User Story (US10.1):** Sebagai *Admin*, saya ingin bisa *melihat semua pesanan yang masuk*.
*   **User Story (US10.2):** Sebagai *Admin*, saya ingin bisa *mengubah status pesanan* (konfirmasi pembayaran, tugaskan cleaner, tandai selesai).
*   **User Story (US10.3):** Sebagai *Admin*, saya ingin bisa *melihat detail bukti pembayaran*.
*   **Kriteria Penerimaan (AC):**
    *   Perubahan status tersimpan di koleksi `bookings` Appwrite.

#### 3.4.3. F11 (Admin): Manajemen Cleaner (Dasar)
*   **User Story (US11.1):** Sebagai *Admin*, saya ingin bisa *menambah, melihat, dan mengedit data dasar cleaner* (nama, kontak).
*   **Kriteria Penerimaan (AC):**
    *   Data cleaner tersimpan di koleksi `cleaners` Appwrite.

---

## 4. Kebutuhan Antarmuka Eksternal

### 4.1. Antarmuka Pengguna (UI)
*   Desain antarmuka harus sesuai dengan pedoman desain **Material Design untuk Android** (atau desain kustom Flutter yang dioptimalkan untuk Android).
*   Intuitif dan mudah digunakan di layar sentuh.
*   Navigasi yang jelas (misalnya, Bottom Navigation Bar, Drawer).

### 4.2. Antarmuka Perangkat Keras
*   Aplikasi akan berinteraksi dengan kamera perangkat Android untuk upload bukti pembayaran.
*   Akses internet (WiFi/Mobile Data).

### 4.3. Antarmuka Perangkat Lunak
*   **Appwrite SDK (Flutter):** Aplikasi Flutter akan menggunakan Appwrite Flutter SDK untuk berinteraksi dengan layanan backend Appwrite.
*   **Sistem Operasi Mobile:** **Android**.

### 4.4. Antarmuka Komunikasi
*   Komunikasi antara aplikasi Flutter dan backend Appwrite akan melalui HTTPS.

## 5. Kebutuhan Non-Fungsional

### 5.1. Kebutuhan Performa
*   Waktu startup aplikasi yang cepat.
*   Responsivitas UI yang lancar, animasi halus.
*   Waktu muat data dari backend yang wajar.

### 5.2. Kebutuhan Keamanan
*   Autentikasi pengguna yang aman (Appwrite Auth).
*   Penyimpanan data sensitif (jika ada di lokal) harus dienkripsi.
*   Data transmisi melalui HTTPS.
*   Pembatasan akses data berdasarkan peran pengguna (Admin vs Customer) menggunakan Appwrite Permissions dan/atau Teams.

### 5.3. Kebutuhan Keandalan (Reliability)
*   Aplikasi harus stabil dan minim crash.
*   Data harus konsisten antara aplikasi dan backend.

### 5.4. Kebutuhan Ketersediaan (Availability)
*   Tergantung pada uptime Appwrite dan ketersediaan koneksi internet pengguna.

### 5.5. Kebutuhan Pemeliharaan (Maintainability)
*   Kode Flutter harus terstruktur dengan baik (misalnya, menggunakan arsitektur seperti BLoC, Provider, Riverpod, atau GetX).
*   Kode mudah dipahami dan dimodifikasi.
*   Penggunaan widget yang reusable.

### 5.6. Kebutuhan Skalabilitas
*   Backend Appwrite dapat diskalakan.
*   Aplikasi Flutter harus dirancang untuk menangani peningkatan jumlah data tanpa penurunan performa signifikan.

### 5.7. Kebutuhan Usabilitas
*   Mudah dipelajari dan digunakan oleh target pengguna.
*   Pesan error yang jelas dan membantu.
*   Alur pengguna yang intuitif.

## 6. Kebutuhan Data (Skema Database Awal - Appwrite Single Project)

Satu Project Appwrite dengan satu Database utama (`DATABASE_ID` akan merujuk ke ID database ini).

### 6.1. Koleksi `users`
*   `$id` (string, Appwrite generated, ID Pengguna)
*   `name` (string, required)
*   `email` (string, required, unique)
*   `password` (string, Appwrite Auth managed)
*   `phoneNumber` (string, optional)
*   `role` (string, enum: "customer", "admin", default: "customer" - bisa disimpan di User Prefs Appwrite atau menggunakan Appwrite Teams)
*   `$createdAt`, `$updatedAt` (datetime, Appwrite generated)
    *   *Permissions: Pengguna dapat membaca/memperbarui data mereka sendiri. Admin mungkin memiliki akses baca lebih luas jika diperlukan untuk manajemen.*

### 6.2. Koleksi `services`
*   `$id` (string, Appwrite generated, ID Layanan)
*   `name` (string, required)
*   `description` (string, required)
*   `basePrice` (number, required)
*   `estimatedDuration` (string, optional)
*   `imageUrl` (string, opsional, URL gambar layanan)
*   `isActive` (boolean, default: true)
*   `$createdAt`, `$updatedAt`
    *   *Permissions: Admin dapat CRUD. Customer dapat Read.*

### 6.3. Koleksi `bookings`
*   `$id` (string, Appwrite generated, ID Pesanan)
*   `userId` (string, required, relation to `users.$id` - ID Customer)
*   `customerName` (string, denormalisasi)
*   `serviceId` (string, required, relation to `services.$id`)
*   `serviceName` (string, denormalisasi)
*   `bookingAddress` (string, required)
*   `bookingDate` (datetime, required)
*   `bookingTimeSlot` (string, required)
*   `notes` (string, optional)
*   `totalPrice` (number, required)
*   `paymentStatus` (string, enum: "PENDING_PAYMENT", "AWAITING_CONFIRMATION", "PAID", "FAILED", default: "PENDING_PAYMENT")
*   `bookingStatus` (string, enum: "PENDING_ADMIN_CONFIRMATION", "CONFIRMED", "ASSIGNED_TO_CLEANER", "ONGOING", "COMPLETED", "CANCELLED", default: "PENDING_ADMIN_CONFIRMATION")
*   `proofOfPaymentUrl` (string, optional)
*   `assignedCleanerId` (string, optional, relation to `cleaners.$id`)
*   `adminNotes` (string, optional)
*   `$createdAt`, `$updatedAt`
    *   *Permissions: Customer (pemilik `userId`) dapat Create dan Read/Update (terbatas) pesanannya. Admin dapat CRUD semua pesanan.*

### 6.4. Koleksi `cleaners`
*   `$id` (string, Appwrite generated, ID Cleaner)
*   `name` (string, required)
*   `phoneNumber` (string, optional)
*   `isActive` (boolean, default: true)
*   `$createdAt`, `$updatedAt`
    *   *Permissions: Admin dapat CRUD.*

### 6.5. (Opsional) Koleksi `app_settings`
*   `$id` (string, Appwrite generated)
*   `key` (string, required, unique, mis: "bankAccountNumber", "bankName", "adminContact")
*   `value` (string, required)
    *   *Permissions: Admin dapat CRUD. Aplikasi Flutter dapat Read.*

## 7. Glosarium
*   **SRS:** Software Requirements Specification
*   **MVP:** Minimum Viable Product
*   **Flutter:** UI toolkit dari Google.
*   **Appwrite:** Backend as a Service (BaaS).
*   **Single-Tenant:** Arsitektur untuk satu bisnis/organisasi.
*   **SDK:** Software Development Kit.
*   **UI/UX:** User Interface/User Experience.
*   **API:** Application Programming Interface.
*   **CRUD:** Create, Read, Update, Delete.
*   **BLoC/Provider/Riverpod/GetX:** Pola manajemen state di Flutter.
*   **HTTPS:** Hypertext Transfer Protocol Secure.
*   **NoSQL:** Jenis database non-relasional.
*   **Android:** Sistem operasi mobile yang menjadi target utama pengembangan aplikasi ini.

## 8. Apendiks
*   Diagram Alur Pengguna Utama (Customer) terdapat di Bagian 2.4.
*   Diagram Sequence Alur Program Aplikasi terdapat di Bagian 2.7.
*   (Dapat ditambahkan: Mockups UI/UX Awal untuk aplikasi Android).

---