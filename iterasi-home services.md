# Panduan Iterasi Pembangunan MVP Aplikasi Home Services (Flutter Android - Single Tenant)

Ini adalah panduan langkah demi langkah untuk membangun Minimum Viable Product (MVP) aplikasi Home Services berdasarkan SRS Versi 2.1. Gunakan checklist box untuk menandai progres Anda.

## Prasyarat Sebelum Memulai:

- [✅] **Setup Lingkungan Pengembangan Flutter:**
    - [✅] Flutter SDK terinstall dan `flutter doctor` tidak menunjukkan error kritis.
    - [✅] Android Studio / VS Code dengan ekstensi Flutter & Dart terinstall.
    - [✅] Emulator Android terkonfigurasi, atau perangkat Android fisik siap untuk testing.
- [✅] **Instance Appwrite Siap:**
    - [✅] Appwrite (Cloud atau self-hosted) sudah berjalan dan bisa diakses.
    - [✅] Project Appwrite baru sudah dibuat khusus untuk aplikasi ini.
- [✅] **Pemahaman Dasar:**
    - [✅] Dasar-dasar Dart dan Flutter (Widgets, State Management).
    - [✅] Dasar-dasar Appwrite (Auth, Databases, Storage, Permissions).
- [✅] **Desain UI/UX Awal (Wireframes/Mockups):**
    - [✅] Gambaran kasar tata letak halaman utama aplikasi mobile Android.

---

## Iterasi 0: Persiapan & Konfigurasi Awal (Fondasi Flutter & Appwrite)

*   **Estimasi Durasi:** 1 Minggu
*   **Tujuan:** Menyiapkan struktur proyek Flutter, koneksi dasar ke Project Appwrite, dan state management awal.
*   **Langkah-langkah:**
    - [✅] **Buat Proyek Flutter Baru:**
        - [✅] Gunakan `flutter create [nama_proyek_anda]`.
        - [✅] Buka proyek di IDE (Android Studio / VS Code).
    - [✅] **Install Appwrite Flutter SDK:**
        - [✅] Tambahkan `appwrite` ke `pubspec.yaml` dan jalankan `flutter pub get`.
    - [✅] **Konfigurasi Project Appwrite (Manual):**
        - [✅] Catat **Project ID** dan **API Endpoint** dari Appwrite Console.
        - [✅] Tambahkan **Platform Flutter (Android)** di Appwrite Console dengan Application ID yang sesuai dari `android/app/build.gradle`. (Platform iOS tidak perlu ditambahkan untuk fokus saat ini).
        - [✅] Aktifkan layanan **Auth** (Email/Password provider).
    - [✅] **Konfigurasi Appwrite Client di Flutter:**
        - [✅] Buat file konfigurasi atau service untuk inisialisasi Appwrite `Client` dengan Project ID dan API Endpoint. Simpan kredensial ini dengan aman (misalnya menggunakan `flutter_dotenv`).
        - [✅] Sediakan instance layanan Appwrite (Account, Databases, Storage) melalui dependency injection atau state management.
    - [✅] **Setup State Management (Pilih salah satu: Provider, Riverpod, BLoC, GetX):**
        - [✅] Install package state management yang dipilih.
        - [✅] Konfigurasi dasar dan buat provider/store awal untuk Autentikasi.
    - [✅] **Struktur Folder Proyek Flutter:**
        - [✅] Atur struktur folder yang baik (misalnya, per fitur atau per layer: `data`, `domain`, `presentation`).
    - [✅] **Buat Navigasi Dasar (Routing):**
        - [✅] Setup sistem routing Flutter (misalnya, menggunakan `Navigator 2.0` atau package seperti `go_router`).
        - [✅] Buat beberapa halaman placeholder awal.
    - [✅] **Jalankan Aplikasi Flutter di Emulator/Device Android:**
        - [✅] Pastikan aplikasi dasar Flutter bisa berjalan tanpa error di lingkungan Android.
*   **Fitur SRS yang Didukung Sebagian:** Fondasi untuk semua fitur.
*   **Output Iterasi:** Proyek Flutter yang bisa terkoneksi ke Appwrite, dengan state management dan routing dasar siap untuk pengembangan fitur Android.

---

## Iterasi 1: Autentikasi Pengguna (Customer & Admin)

*   **Estimasi Durasi:** 2 Minggu
*   **Tujuan:** Mengimplementasikan registrasi dan login untuk Customer dan Admin di aplikasi Android, serta halaman profil dasar Customer.
*   **Langkah-langkah:**
    - [✅] **Buat Halaman & Widget UI Mobile (Material Design):**
        - [✅] Halaman Splash Screen (opsional).
        - [✅] Halaman Selamat Datang / Pilihan Awal.
        - [✅] Halaman Registrasi (`RegisterScreen.dart`) dengan form (nama, email, password).
        - [✅] Halaman Login (`LoginScreen.dart`) dengan form (email, password).
        - [✅] Halaman Profil Customer (`CustomerProfileScreen.dart`).
        - [✅] Widget Form input yang reusable.
    - [✅] **Implementasi Fungsi Registrasi (Customer):**
        - [✅] Di state management/logic terkait `RegisterScreen`:
            - [✅] Panggil `appwrite.account.create(userId: ID.unique(), email: email, password: password, name: name)`.
            - [✅] Tangani respons sukses (simpan user ke state, arahkan) dan error.
            - [✅] **Penting:** Saat registrasi, set `role` pengguna menjadi "customer" (bisa dilakukan dengan Appwrite Function yang terpicu setelah user create, atau default di koleksi `users`).
    - [✅] **Implementasi Fungsi Login (Customer & Admin):**
        - [✅] Di state management/logic terkait `LoginScreen`:
            - [✅] Panggil `appwrite.account.createEmailSession(email: email, password: password)`.
            - [✅] Tangani respons sukses (simpan sesi & user ke state).
            - [✅] Ambil data `role` pengguna (dari Appwrite User Prefs `appwrite.account.getPrefs()` atau atribut di dokumen `users`).
            - [✅] Arahkan ke Dashboard Customer atau Dashboard Admin berdasarkan `role`.
    - [✅] **Implementasi Fungsi Logout:**
        - [✅] Tambahkan tombol logout.
        - [✅] Panggil `appwrite.account.deleteSession(sessionId: 'current')`.
        - [✅] Bersihkan state pengguna dan arahkan ke halaman login.
    - [✅] **Implementasi Halaman Profil Customer:**
        - [✅] Tampilkan informasi Customer (nama, email) dari state.
        - [✅] Fungsi untuk mengedit nama dan nomor telepon Customer:
            - [✅] `appwrite.account.updateName(name: newName)`.
            - [✅] `appwrite.account.updatePhone(phone: newPhone)`.
            - [✅] Update state setelah berhasil.
    - [✅] **Route Guards (Navigasi Terproteksi):**
        - [✅] Implementasikan proteksi rute berdasarkan status login dan peran pengguna.
    - [✅] **Setup Koleksi `users` di Appwrite (Manual):**
        - [✅] Atribut: `$id`, `name`, `email`, `phoneNumber`, `role` (string: "customer" atau "admin"), `$createdAt`, `$updatedAt`.
        - [✅] (Untuk peran Admin, Super Admin/pemilik bisnis membuatkan akun Admin secara manual dengan role "admin").
        - [✅] Permissions: Atur agar pengguna bisa membaca dan memperbarui data mereka sendiri.
*   **Fitur SRS yang Didukung:** F01, F02, F03.
*   **Output Iterasi:** Customer bisa mendaftar, login, logout, dan mengelola profil dasar. Admin bisa login dan diarahkan ke placeholder dashboard admin. Aplikasi Android memiliki proteksi rute.

---

## Iterasi 2: Penelusuran & Pemesanan Layanan oleh Customer

*   **Estimasi Durasi:** 2 Minggu
*   **Tujuan:** Customer dapat melihat layanan yang ditawarkan dan melakukan pemesanan melalui aplikasi Android.
*   **Langkah-langkah:**
    - [✅] **Setup Koleksi `services` & `bookings` di Appwrite (Manual):**
        - [✅] Buat koleksi `services` dengan atribut sesuai SRS (nama, deskripsi, harga, isActive, dll.). Isi beberapa data dummy. Permissions: Admin CRUD, Customer Read. (Pastikan ID Database sudah benar).
        - [✅] Buat koleksi `bookings` dengan atribut sesuai SRS (userId, serviceId, alamat, tanggal, status, dll.). Permissions: Customer Create & Read/Update terbatas miliknya, Admin CRUD semua.
    - [✅] **Halaman Utama/Dashboard Customer (`CustomerHomeScreen.dart`):**
        - [✅] Tampilkan daftar layanan aktif dari koleksi `services`:
            - [✅] Panggil `appwrite.databases.listDocuments(databaseId: 'YOUR_DATABASE_ID', collectionId: 'services', queries: [Query.equal('isActive', true)])`.
        - [✅] Setiap item layanan bisa diklik untuk melihat detail atau langsung memesan.
    - [✅] **(Opsional) Halaman Detail Layanan (`ServiceDetailScreen.dart`):**
        - [✅] Tampilkan informasi lengkap satu layanan. Tombol "Pesan Layanan".
    - [✅] **Halaman Form Pemesanan (`BookingFormScreen.dart`):**
        - [✅] Widget untuk input alamat manual.
        - [✅] Widget pemilih tanggal (misalnya, `showDatePicker`).
        - [✅] Widget pemilih slot waktu.
        - [✅] Input catatan tambahan.
    - [✅] **Halaman Ringkasan Pesanan (`BookingSummaryScreen.dart`):**
        - [✅] Tampilkan semua detail pesanan untuk direview customer.
        - [✅] Hitung total harga.
    - [✅] **Implementasi Logika Pembuatan Pesanan:**
        - [✅] Saat customer konfirmasi di `BookingSummaryScreen`:
            - [✅] Ambil `userId` customer yang login.
            - [✅] Siapkan objek `dataPesanan`.
            - [✅] Panggil `appwrite.databases.createDocument(databaseId: 'YOUR_DATABASE_ID', collectionId: 'bookings', documentId: ID.unique(), data: dataPesanan)`.
            - [✅] Set status awal pesanan (misalnya, `PENDING_PAYMENT`).
            - [✅] Arahkan ke halaman instruksi pembayaran.
*   **Fitur SRS yang Didukung:** F04, F05.
*   **Output Iterasi:** Customer dapat melihat daftar layanan dan berhasil membuat pesanan yang tersimpan di Appwrite melalui aplikasi Android.

---

## Iterasi 3: Pembayaran, Pelacakan Status, & Riwayat Pesanan (Customer)

*   **Estimasi Durasi:** 2 Minggu
*   **Tujuan:** Customer dapat melakukan pembayaran (simulasi transfer), mengupload bukti, melacak status pesanan, dan melihat riwayat pesanannya di aplikasi Android.
*   **Langkah-langkah:**
    - [ ] **Setup Bucket Penyimpanan Bukti Bayar di Appwrite (Manual):**
        - [ ] Buat Bucket baru di Appwrite Storage (misalnya, `bukti-pembayaran`).
        - [ ] Atur permission agar pengguna yang login bisa `create` file.
    - [ ] **Halaman Instruksi Pembayaran (`PaymentInstructionScreen.dart`):**
        - [ ] Tampilkan detail rekening bank bisnis (bisa dari `app_settings` atau hardcode untuk MVP) dan total tagihan.
    - [ ] **Halaman Upload Bukti Pembayaran (`ProofOfPaymentUploadScreen.dart`):**
        - [ ] Gunakan package seperti `image_picker` untuk memilih gambar dari galeri atau kamera perangkat Android.
        - [ ] Fungsi upload ke Appwrite Storage:
            - [ ] Panggil `appwrite.storage.createFile(bucketId: 'ID_BUCKET_BUKTI', fileId: ID.unique(), file: InputFile.fromPath(path: filePath))`.
        - [ ] Setelah file terupload, dapatkan `fileId` atau URL.
        - [ ] Update dokumen `bookings` yang relevan dengan `proofOfPaymentUrl` dan set `paymentStatus: 'AWAITING_CONFIRMATION'`.
            - [ ] `appwrite.databases.updateDocument(databaseId: 'YOUR_DATABASE_ID', collectionId: 'bookings', documentId: bookingId, data: { ... })`.
    - [ ] **Halaman Riwayat Pesanan Customer (`CustomerBookingsHistoryScreen.dart`):**
        - [ ] Tampilkan daftar pesanan milik customer yang login:
            - [ ] `appwrite.databases.listDocuments(databaseId: 'YOUR_DATABASE_ID', collectionId: 'bookings', queries: [Query.equal('userId', currentUser.$id)])`.
        - [ ] Setiap item menampilkan info kunci (layanan, tanggal, status, harga).
    - [ ] **Halaman Detail Pesanan Customer (`CustomerBookingDetailScreen.dart`):**
        - [ ] Tampilkan semua detail pesanan, termasuk status terbaru dan link lihat bukti bayar.
    - [ ] **Logika Update Status Pesanan (Dasar):**
        - [ ] Customer bisa melihat status yang diubah oleh Admin.
*   **Fitur SRS yang Didukung:** F06, F07, F08.
*   **Output Iterasi:** Customer dapat menyelesaikan alur pembayaran (simulasi), mengupload bukti, dan melihat status serta riwayat pesanannya di aplikasi Android.

---

## Iterasi 4: Manajemen Admin (Layanan, Pesanan, Cleaner)

*   **Estimasi Durasi:** 2.5 Minggu
*   **Tujuan:** Admin dapat mengelola layanan, pesanan masuk (termasuk verifikasi pembayaran dan update status), dan data cleaner melalui aplikasi Android atau panel admin sederhana.
*   **Langkah-langkah:**
    - [ ] **Setup Koleksi `cleaners` dan (Opsional) `app_settings` di Appwrite (Manual):**
        - [ ] `cleaners`: atribut nama, kontak, isActive. Permissions: Admin CRUD.
        - [ ] `app_settings`: atribut key, value (misal untuk info bank). Permissions: Admin CRUD, App Read.
    - [ ] **Buat Tampilan/Bagian Admin di Aplikasi Flutter (Android):**
        - [ ] Navigasi khusus untuk Admin setelah login (misalnya, Drawer atau Tab terpisah).
        - [ ] Halaman Dashboard Admin (placeholder atau ringkasan).
    - [ ] **Manajemen Layanan oleh Admin (`AdminServicesScreen.dart`, `AdminServiceFormScreen.dart`):**
        - [ ] Tampilkan daftar layanan.
        - [ ] Fungsi Tambah, Edit, Nonaktifkan/Aktifkan layanan (CRUD pada koleksi `services`).
    - [ ] **Manajemen Pesanan oleh Admin (`AdminBookingsScreen.dart`, `AdminBookingDetailScreen.dart`):**
        - [ ] Tampilkan daftar semua pesanan.
        - [ ] Lihat detail pesanan, termasuk bukti pembayaran.
        - [ ] Fungsi untuk memverifikasi pembayaran dan mengubah `paymentStatus` dan `bookingStatus` pesanan.
        - [ ] (Opsional) Fungsi untuk menugaskan `assignedCleanerId` ke pesanan.
    - [ ] **Manajemen Cleaner oleh Admin (`AdminCleanersScreen.dart`, `AdminCleanerFormScreen.dart`):**
        - [ ] Tampilkan daftar cleaner.
        - [ ] Fungsi Tambah, Edit, Nonaktifkan/Aktifkan data cleaner (CRUD pada koleksi `cleaners`).
    - [ ] **Implementasi Notifikasi Push Dasar untuk Android (Opsional untuk MVP):**
        - [ ] Jika Admin mengubah status pesanan, kirim notifikasi ke Customer (memerlukan setup Appwrite Push Notifications dan package `firebase_messaging` atau `flutter_local_notifications` di Flutter).
*   **Fitur SRS yang Didukung:** F09, F10, F11.
*   **Output Iterasi:** Admin dapat mengelola aspek operasional inti bisnis melalui aplikasi Android. Alur kerja dari pemesanan hingga penyelesaian layanan dapat dikelola.

---

## Iterasi 5: Penyempurnaan, Testing, & Persiapan Peluncuran MVP (Android)

*   **Estimasi Durasi:** 1.5 Minggu
*   **Tujuan:** Memastikan semua fitur MVP berfungsi dengan baik di Android, memperbaiki bug, melakukan penyempurnaan UI/UX dasar, dan mempersiapkan peluncuran ke Google Play Store.
*   **Langkah-langkah:**
    - [ ] **Pengujian End-to-End Komprehensif (Android):**
        - [ ] Uji semua alur pengguna untuk peran Customer di perangkat Android.
        - [ ] Uji semua alur pengguna untuk peran Admin di perangkat Android.
        - [ ] Uji di berbagai perangkat dan versi OS Android.
    - [ ] **Perbaikan Bug:** Atasi semua masalah fungsional dan visual yang ditemukan.
    - [ ] **Penyempurnaan UI/UX Dasar (Material Design):**
        - [ ] Pastikan konsistensi tampilan dan pengalaman pengguna di seluruh aplikasi Android.
        - [ ] Perbaiki alur yang kurang intuitif.
        - [ ] Pastikan pesan error/sukses jelas dan informatif.
    - [ ] **Review Keamanan:**
        - [ ] Double-check permission Appwrite.
    - [ ] **Optimasi Performa Dasar (Android):**
        - [ ] Cek penggunaan memori dan CPU.
        - [ ] Optimalkan build size APK.
    - [ ] **Persiapan Materi Rilis (Google Play Store):**
        - [ ] Siapkan ikon aplikasi, screenshot (dari aplikasi Android).
        - [ ] Tulis deskripsi aplikasi.
    - [ ] **Build Aplikasi Android untuk Rilis:**
        - [ ] Ikuti panduan Flutter untuk membuat build rilis APK atau App Bundle (`.aab`).
        - [ ] Lakukan signing aplikasi.
    - [ ] **Testing Build Rilis Android:**
        - [ ] Uji build rilis di perangkat Android fisik sebelum diunggah.
    - [ ] **Persiapan Unggah ke Google Play Store:**
        - [ ] Buat akun Google Play Console (jika belum).
        - [ ] Siapkan semua aset dan metadata yang diperlukan.
*   **Fitur SRS yang Didukung:** Semua fitur MVP (F01-F11) diuji, disempurnakan, dan divalidasi untuk platform Android.
*   **Output Iterasi:** Aplikasi MVP Flutter Android yang stabil, teruji, dan siap untuk diunggah ke Google Play Store.

---

**Catatan Umum Selama Pengembangan:**

*   **Fokus pada Android:** Desain dan uji dengan prioritas pada pengalaman mobile Android.
*   **Widget Reusable:** Buat komponen UI (widget) yang bisa digunakan kembali.
*   **Error Handling:** Implementasikan penanganan error yang baik.
*   **Version Control (Git):** Gunakan Git secara konsisten.
*   **Testing Lokal:** Sering lakukan testing di emulator Android dan perangkat fisik Android.

Semoga panduan iterasi yang telah diperbarui ini semakin memperjelas langkah-langkah pengembangan aplikasi Android Anda!