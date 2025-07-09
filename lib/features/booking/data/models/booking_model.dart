import 'package:appwrite/models.dart' as appwrite_models;

class BookingModel {
  final String id; // $id
  final String userId;
  final String? customerName; // Opsional, denormalisasi
  final String servicesId;
  final String? servicesName; // Opsional, denormalisasi
  final String bookingAddrees;
  final DateTime bookingDate; // Kita akan parse dari ISO String
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
    required this.servicesId,
    this.servicesName,
    required this.bookingAddrees,
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
    return BookingModel(
      id: doc.$id,
      userId: doc.data['userId'] as String,
      customerName: doc.data['customerName'] as String?,
      servicesId: doc.data['servicesId'] as String,
      servicesName: doc.data['servicesName'] as String?,
      bookingAddrees: doc.data['bookingAddress'] as String,
      bookingDate: DateTime.parse(doc.data['bookingDate'] as String), // Parse ISO String
      bookingTimeSlot: doc.data['bookingTimeSlot'] as String,
      notes: doc.data['notes'] as String?,
      totalPrice: (doc.data['totalPrice'] as num).toDouble(),
      paymentStatus: doc.data['paymentStatus'] as String,
      bookingStatus: doc.data['bookingStatus'] as String,
      proofOfPaymentUrl: doc.data['proofOfPaymentUrl'] as String?,
      assignedCleanerId: doc.data['assignedCleanerId'] as String?,
      adminNotes: doc.data['adminNotes'] as String?,
      createdAt: DateTime.parse(doc.$createdAt as String), // Parse ISO String
    );
  }
}