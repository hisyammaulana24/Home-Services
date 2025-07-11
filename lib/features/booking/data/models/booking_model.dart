import 'package:appwrite/models.dart' as appwrite_models;

class BookingModel {
  final String id; // $id
  final String userId;
  final String? customerName;
  final String servicesId; // Disesuaikan dengan DB
  final String? servicesName; // Disesuaikan dengan DB
  final String bookingAddrees; // Disesuaikan dengan DB
  final DateTime bookingDate;
  final String bookingTimeSlot;
  final String? notes;
  final double totalPrice;
  final String paymentStatus;
  final String bookingStatus;
  final String? proofOfPaymentUrl;
  final String? assignedCleanerId;
  final String? adminNotes;
  final DateTime createdAt; // $createdAt

  BookingModel({
    required this.id,
    required this.userId,
    this.customerName,
    required this.servicesId, // Disesuaikan
    this.servicesName,   // Disesuaikan
    required this.bookingAddrees, // Disesuaikan
    required this.bookingDate,
    required this.bookingTimeSlot,
    this.notes,
    required this.totalPrice,
    required this.paymentStatus,
    required this.bookingStatus,
    this.proofOfPaymentUrl,
    this.assignedCleanerId,
    this.adminNotes,
    required this.createdAt,
  });

  factory BookingModel.fromAppwriteDocument(appwrite_models.Document doc) {
    try {
      final data = doc.data; // Simpan data ke variabel agar mudah dibaca

      // Helper functions untuk parsing yang lebih aman
      String getString(String key, {String defaultValue = ''}) {
        return data[key] as String? ?? defaultValue;
      }

      String? getNullableString(String key) {
        return data[key] as String?;
      }

      double getDouble(String key, {double defaultValue = 0.0}) {
        final value = data[key];
        if (value is num) {
          return value.toDouble();
        } else if (value is String) {
          return double.tryParse(value) ?? defaultValue;
        }
        return defaultValue;
      }

      DateTime getDateTime(String key, {bool isSystemAttr = false}) {
        final value = isSystemAttr ? (key == '\$createdAt' ? doc.$createdAt : doc.$updatedAt) : data[key];
        if (value is String) {
          try {
            return DateTime.parse(value);
          } catch (e) {
            print("Error parsing date string '$value' untuk key '$key'. Menggunakan waktu sekarang sebagai fallback.");
            return DateTime.now(); // Fallback
          }
        }
        print("Peringatan: Tipe data yang diharapkan untuk key '$key' adalah String, tapi mendapatkan ${value?.runtimeType}. Menggunakan waktu sekarang sebagai fallback.");
        return DateTime.now(); // Fallback
      }

      // Logging untuk setiap field yang berpotensi error sebelum parsing
      print('--- [Parsing Document] Memproses Dokumen Booking ID: ${doc.$id} ---');
      print('userId: ${data['userId']} (Tipe: ${data['userId']?.runtimeType})');
      print('servicesId: ${data['servicesId']} (Tipe: ${data['servicesId']?.runtimeType})');
      print('bookingAddrees: ${data['bookingAddrees']} (Tipe: ${data['bookingAddrees']?.runtimeType})');
      print('bookingDate (String): ${data['bookingDate']} (Tipe: ${data['bookingDate']?.runtimeType})');
      print('bookingTimeSlot: ${data['bookingTimeSlot']} (Tipe: ${data['bookingTimeSlot']?.runtimeType})');
      print('totalPrice: ${data['totalPrice']} (Tipe: ${data['totalPrice']?.runtimeType})');
      print('paymentStatus: ${data['paymentStatus']} (Tipe: ${data['paymentStatus']?.runtimeType})');
      print('bookingStatus: ${data['bookingStatus']} (Tipe: ${data['bookingStatus']?.runtimeType})');
      print('doc.\$createdAt (String): ${doc.$createdAt} (Tipe: ${doc.$createdAt.runtimeType})');
      print('-----------------------------------------------------------------');

      return BookingModel(
        id: doc.$id,
        userId: getString('userId'),
        customerName: getNullableString('customerName'),
        servicesId: getString('servicesId'), // Menggunakan key yang benar dari DB Anda
        servicesName: getNullableString('servicesName'), // Menggunakan key yang benar dari DB Anda
        bookingAddrees: getString('bookingAddrees'), // Menggunakan key yang benar dari DB Anda
        bookingDate: getDateTime('bookingDate'),
        bookingTimeSlot: getString('bookingTimeSlot'),
        notes: getNullableString('notes'),
        totalPrice: getDouble('totalPrice'),
        paymentStatus: getString('paymentStatus', defaultValue: 'UNKNOWN'),
        bookingStatus: getString('bookingStatus', defaultValue: 'UNKNOWN'),
        proofOfPaymentUrl: getNullableString('proofOfPaymentUrl'),
        assignedCleanerId: getNullableString('assignedCleanerId'),
        adminNotes: getNullableString('adminNotes'),
        createdAt: getDateTime('\$createdAt', isSystemAttr: true),
      );
    } catch (e, stacktrace) {
      print("!!! ERROR saat parsing dokumen ID: ${doc.$id} !!!");
      print("Error Parsing Asli: $e");
      print("Stacktrace Parsing: $stacktrace");
      // Lemparkan kembali error yang lebih deskriptif agar FutureBuilder bisa menampilkannya
      throw Exception("Gagal memproses data booking dari server untuk dokumen ID: ${doc.$id}. Error: $e");
    }
  }
}