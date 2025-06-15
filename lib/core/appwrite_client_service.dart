import 'package:appwrite/appwrite.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppwriteClientService {
  Client client = Client(); // Instance client Appwrite
  // Layanan Appwrite yang akan sering digunakan
  late Account account;
  late Databases databases;
  late Storage storage;
  late Teams teams;

  // Singleton pattern untuk memastikan hanya ada satu instance service ini
  static final AppwriteClientService _instance = AppwriteClientService._internal();

  factory AppwriteClientService() {
    return _instance;
  }

  AppwriteClientService._internal(); // Private constructor untuk Singleton

  // Metode untuk menginisialisasi koneksi ke Appwrite
  Future<void> init() async {
    // 1. Muat variabel environment dari file .env
    try {
      await dotenv.load(fileName: ".env");
    } catch (e) {
      print("Error loading .env file: $e (Pastikan .env ada di root dan terdaftar di pubspec.yaml assets)");
      // Sebaiknya lemparkan error agar aplikasi tahu ada masalah konfigurasi krusial
      throw Exception("Gagal memuat file .env: $e");
    }

    // 2. Ambil Project ID dan API Endpoint dari environment variables
    final String? projectId = dotenv.env['APPWRITE_PROJECT_ID'];
    final String? endpoint = dotenv.env['APPWRITE_API_ENDPOINT'];

    // 3. Validasi apakah projectId dan endpoint ada
    if (projectId == null || projectId.isEmpty) {
      final errorMessage = 'ERROR: APPWRITE_PROJECT_ID tidak valid atau tidak ditemukan di .env';
      print(errorMessage);
      throw Exception(errorMessage);
    }
    if (endpoint == null || endpoint.isEmpty) {
      final errorMessage = 'ERROR: APPWRITE_API_ENDPOINT tidak valid atau tidak ditemukan di .env';
      print(errorMessage);
      throw Exception(errorMessage);
    }

    // 4. Konfigurasi Appwrite Client
    client
        .setEndpoint(endpoint)
        .setProject(projectId);
        // HAPUS .setSelfSigned(status: true); jika menggunakan Appwrite Cloud
        // .setSelfSigned(status: true); // Hanya untuk self-hosted dengan self-signed SSL

    // 5. Inisialisasi layanan Appwrite lainnya
    account = Account(client);
    databases = Databases(client);
    storage = Storage(client);
    teams = Teams(client);

    print('Appwrite Client Initialized: Endpoint=$endpoint, ProjectID=$projectId');
  }
}