import 'package:appwrite/appwrite.dart';
import 'package:home_services/core/appwrite_client_service.dart'; // Pastikan path ini benar
import 'package:home_services/features/booking/data/models/booking_model.dart'; // Pastikan path ini benar

class BookingRepository {
  final AppwriteClientService _appwriteClientService;

  // GANTI PLACEHOLDER INI DENGAN ID ANDA YANG SEBENARNYA!
  static const String _databaseId = '683f95e1003c6576571c'; // Contoh, gunakan ID database Anda
  static const String _bookingsCollectionId = 'bookings'; // Contoh, gunakan ID koleksi bookings Anda

  BookingRepository(this._appwriteClientService);

  Future<List<BookingModel>> getMyBookings(String userId) async {
    // Menambahkan print untuk memastikan fungsi ini dipanggil dengan userId yang benar
    print('[BookingRepository] getMyBookings dipanggil untuk userId: $userId');
    
    try {
      final response = await _appwriteClientService.databases.listDocuments(
        databaseId: _databaseId,
        collectionId: _bookingsCollectionId,
        queries: [
          Query.equal('userId', userId), // Filter berdasarkan userId customer
          Query.orderDesc('\$createdAt'), // Urutkan berdasarkan terbaru
        ],
      );
      
      print('[BookingRepository] Berhasil mengambil ${response.documents.length} dokumen dari Appwrite.');
      
      // Proses mapping data, di mana error casting mungkin terjadi
      final bookings = response.documents
          .map((doc) => BookingModel.fromAppwriteDocument(doc))
          .toList();
          
      print('[BookingRepository] Berhasil memetakan ${bookings.length} dokumen ke BookingModel.');
      return bookings;

    } on AppwriteException catch (e) {
      // Menangkap error spesifik dari Appwrite (misalnya, permission, query salah)
      print('[BookingRepository] --- ERROR APPWRITE EXCEPTION (getMyBookings) ---');
      print('[BookingRepository] Pesan Error: ${e.message}');
      print('[BookingRepository] Kode Error: ${e.code}');
      print('[BookingRepository] Tipe Error: ${e.type}');
      print('[BookingRepository] Respons Lengkap Error: ${e.response}');
      print('[BookingRepository] ---------------------------------------------');
      throw Exception('Gagal mengambil riwayat pesanan: ${e.message}');
    
    } catch (e, stacktrace) { // Menangkap error lain, seperti error casting tipe data
      print('[BookingRepository] --- ERROR UMUM (getMyBookings) ---');
      print('[BookingRepository] Error Asli: $e');
      print('[BookingRepository] STACKTRACE LENGKAP: \n$stacktrace'); // Ini akan menunjukkan lokasi error
      print('[BookingRepository] ----------------------------------');
      throw Exception('Terjadi kesalahan tidak diketahui saat memuat riwayat pesanan.');
    }
  }

  // Fungsi untuk update bukti pembayaran, dilengkapi dengan logging yang lebih baik juga
  Future<void> updateBookingProof(String bookingId, String uploadedFileId) async {
    // Untuk saat ini kita simpan fileId langsung, implementasi URL bisa menyusul
    try {
      await _appwriteClientService.databases.updateDocument(
          databaseId: _databaseId,
          collectionId: _bookingsCollectionId,
          documentId: bookingId,
          data: {
            'proofOfPaymentUrl': uploadedFileId, 
            'paymentStatus': 'AWAITING_CONFIRMATION'
          });
      print('[BookingRepository] Bukti pembayaran (fileId: $uploadedFileId) berhasil diupdate untuk booking $bookingId');
    
    } on AppwriteException catch (e) {
      print('[BookingRepository] --- ERROR APPWRITE EXCEPTION (updateBookingProof) ---');
      print('[BookingRepository] Pesan Error: ${e.message}');
      print('[BookingRepository] Respons Lengkap Error: ${e.response}');
      print('[BookingRepository] ---------------------------------------------------');
      throw Exception('Gagal mengupdate bukti pembayaran: ${e.message}');
    
    } catch (e, stacktrace) {
      print('[BookingRepository] --- ERROR UMUM (updateBookingProof) ---');
      print('[BookingRepository] Error: $e');
      print('[BookingRepository] Stacktrace: $stacktrace');
      print('[BookingRepository] ---------------------------------------');
      throw Exception('Terjadi kesalahan tidak diketahui saat mengupdate bukti pembayaran.');
    }
  }
}