import 'package:appwrite/appwrite.dart';
import 'package:home_services/core/appwrite_client_service.dart'; // Sesuaikan path
import 'package:home_services/features/booking/data/models/booking_model.dart'; // Sesuaikan path

class BookingRepository {
  final AppwriteClientService _appwriteClientService;

  static const String _databaseId =
      '683f95e1003c6576571c'; // GANTI DENGAN ID DATABASE ANDA
  static const String _bookingsCollectionId =
      'bookings'; // GANTI DENGAN ID KOLEKSI BOOKINGS ANDA

  BookingRepository(this._appwriteClientService);
  Future<List<BookingModel>> getMyBookings(String userId) async {
    try {
      final response = await _appwriteClientService.databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _bookingsCollectionId,
        queries: [
          Query.equal('userId', userId), // Filter berdasarkan userId customer
          Query.orderDesc('\$createdAt'), // Urutkan berdasarkan terbaru
        ],
      );
      final bookings = response.documents
          .map((doc) => BookingModel.fromAppwriteDocument(doc))
          .toList();
      print(
          '[BookingRepository] Booking berhasil diambil untuk user $userId: ${bookings.length} item');
      return bookings;
    } on AppwriteException catch (e) {
      print('[BookingRepository] Error mengambil booking: ${e.message}');
      throw Exception('Gagal mengambil riwayat pesanan: ${e.message}');
    } catch (e) {
      print(
          '[BookingRepository] Error tidak diketahui saat mengambil booking: $e');
      throw Exception(
          'Terjadi kesalahan tidak diketahui saat memuat riwayat pesanan.');
    }
  }

  // Nanti kita tambahkan fungsi untuk update booking (misal, upload bukti bayar)
  Future<void> updateBookingProof(
      String bookingId, String uploadedFileId) async {
    try {
      await _appwriteClientService.databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _bookingsCollectionId,
          documentId: bookingId,
          data: {
            'proofOfPaymentUrl':
                uploadedFileId, // Simpan fileId dari hasil upload storage
            'paymentStatus': 'AWAITING_CONFIRMATION'
          });
      print(
          '[BookingRepository] Bukti pembayaran (fileId: $uploadedFileId) berhasil diupdate untuk booking $bookingId');
    } on AppwriteException catch (e) {
      print('[BookingRepository] Error mengambil booking: ${e.message}');
      print('[BookingRepository] Appwrite Error Response: ${e.response}'); // Ini penting
      throw Exception('Gagal mengambil riwayat pesanan: ${e.message}');
    } catch (e, stacktrace) { // Tambahkan stacktrace di sini
      print('[BookingRepository] Error tidak diketahui saat mengambil booking: $e');
      print('[BookingRepository] Stacktrace: $stacktrace'); // Cetak stacktrace
      throw Exception('Terjadi kesalahan tidak diketahui saat memuat riwayat pesanan.');
    }
  }
}
