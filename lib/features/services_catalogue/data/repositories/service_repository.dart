import 'package:appwrite/appwrite.dart';
import 'package:home_services/core/appwrite_client_service.dart'; 
import 'package:home_services/features/services_catalogue/data/models/service_model.dart';

class ServiceRepository {
  final AppwriteClientService _appwriteClientService;

  // GANTI DENGAN ID DATABASE DAN KOLEKSI SERVICES ANDA YANG SEBENARNYA!
  static const String _databaseId = '683f95e1003c6576571c'; // Contoh, ganti dengan ID Database Anda
  static const String _servicesCollectionId = 'services'; // Contoh, ganti dengan ID Koleksi services Anda

  ServiceRepository(this._appwriteClientService);

  Future<List<ServiceModel>> getActiveServices() async {
    try {
      final response = await _appwriteClientService.databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _servicesCollectionId,
        queries: [
          Query.equal('isActive', true),
          // Query.orderDesc('\$createdAt'), // Opsional: urutkan berdasarkan terbaru
        ],
      );

      final services = response.documents
          .map((doc) => ServiceModel.fromAppwriteDocument(doc))
          .toList();
      print('[ServiceRepository] Layanan aktif berhasil diambil: ${services.length} item');
      return services;
    } on AppwriteException catch (e) {
      print('[ServiceRepository] Error mengambil layanan aktif: ${e.message}');
      print('[ServiceRepository] Appwrite Error Response: ${e.response}');
      throw Exception('Gagal mengambil daftar layanan: ${e.message}');
    } catch (e) {
      print('[ServiceRepository] Error tidak diketahui saat mengambil layanan: $e');
      throw Exception('Terjadi kesalahan tidak diketahui saat memuat layanan.');
    }
  }
}