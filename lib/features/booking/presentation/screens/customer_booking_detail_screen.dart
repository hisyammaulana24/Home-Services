import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Untuk format
// import 'package:image_picker/image_picker.dart'; // Akan dibutuhkan nanti untuk upload
// import 'package:appwrite/appwrite.dart'; // Untuk ID dan AppwriteException
// import '../../../../core/appwrite_client_service.dart';
// import '../repositories/booking_repository.dart'; // Jika update status dari sini

import 'package:home_services/features/booking/data/models/booking_model.dart';

class CustomerBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const CustomerBookingDetailScreen({super.key, required this.booking});

  @override
  State<CustomerBookingDetailScreen> createState() => _CustomerBookingDetailScreenState();
}

class _CustomerBookingDetailScreenState extends State<CustomerBookingDetailScreen> {
  // bool _isUploadingProof = false; // Untuk state loading upload

  // Fungsi untuk memilih gambar (akan diimplementasikan nanti)
  // Future<void> _pickAndUploadProof() async {
  //   // ... logika image_picker dan upload ke Appwrite Storage ...
  //   // ... lalu panggil bookingRepository.updateBookingProof(...) ...
  // }

  @override
  Widget build(BuildContext context) {
    // Helper untuk menampilkan baris detail
    Widget buildDetailRow(String label, String? value, {TextStyle? valueStyle}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120, // Lebar tetap untuk label
              child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Text(value ?? '-', style: valueStyle)),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${widget.booking.id.substring(0, 8)}...'), // Tampilkan sebagian ID
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.booking.servicesName ?? 'Layanan Tidak Diketahui', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            buildDetailRow('ID Pesanan', widget.booking.id),
            buildDetailRow('Tanggal Pesan', DateFormat('EEEE, dd MMM yyyy, HH:mm', 'id_ID').format(widget.booking.createdAt)),
            buildDetailRow('Jadwal Layanan', '${DateFormat('EEEE, dd MMM yyyy', 'id_ID').format(widget.booking.bookingDate)} (${widget.booking.bookingTimeSlot})'),
            buildDetailRow('Alamat Layanan', widget.booking.bookingAddrees),
            if (widget.booking.notes != null && widget.booking.notes!.isNotEmpty)
              buildDetailRow('Catatan Tambahan', widget.booking.notes),
            const Divider(height: 32, thickness: 1),
            buildDetailRow('Status Pesanan', widget.booking.bookingStatus, valueStyle: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(widget.booking.bookingStatus))),
            buildDetailRow('Status Pembayaran', widget.booking.paymentStatus, valueStyle: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(widget.booking.paymentStatus, isPayment: true))),
            buildDetailRow('Total Pembayaran', 'Rp ${NumberFormat("#,##0", "id_ID").format(widget.booking.totalPrice)}', valueStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
            const SizedBox(height: 24),

            // Bagian Upload Bukti Pembayaran (muncul jika status PENDING_PAYMENT)
            if (widget.booking.paymentStatus.toUpperCase() == 'PENDING_PAYMENT')
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Pembayaran Anda masih tertunda.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 8),
                  const Text('Silakan lakukan pembayaran dan unggah bukti Anda di sini.'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.upload_file_outlined),
                    label: const Text('Unggah Bukti Pembayaran'),
                    onPressed: () {
                      // TODO: Panggil _pickAndUploadProof()
                       ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fitur Unggah Bukti belum diimplementasikan.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (widget.booking.proofOfPaymentUrl != null && widget.booking.proofOfPaymentUrl!.isNotEmpty)
                     Padding(
                       padding: const EdgeInsets.only(top:8.0),
                       child: Text('Bukti sudah diunggah (URL: ${widget.booking.proofOfPaymentUrl})', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                     ),
                ],
              ),
            
            if (widget.booking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION')
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('Bukti pembayaran Anda sedang menunggu konfirmasi Admin.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
              ),

            // Anda bisa menambahkan informasi cleaner jika sudah ditugaskan, dll.
            // if (widget.booking.assignedCleanerId != null) ...

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Salin fungsi _getStatusColor dari CustomerBookingsHistoryScreen jika belum ada di file utilitas
  Color _getStatusColor(String status, {bool isPayment = false}) {
    if (isPayment) {
      switch (status.toUpperCase()) {
        case 'PENDING_PAYMENT': return Colors.orange.shade700;
        case 'AWAITING_CONFIRMATION': return Colors.blue.shade700;
        case 'PAID': return Colors.green.shade700;
        case 'FAILED': return Colors.red.shade700;
        default: return Colors.grey.shade700;
      }
    } else { // Untuk bookingStatus
      switch (status.toUpperCase()) {
        case 'PENDING_ADMIN_CONFIRMATION': return Colors.orange.shade700;
        case 'CONFIRMED': return Colors.blue.shade700;
        case 'ASSIGNED_TO_CLEANER': return Colors.lightBlue.shade700;
        case 'ONGOING': return Colors.teal.shade700;
        case 'COMPLETED': return Colors.green.shade700;
        case 'CANCELLED': return Colors.red.shade700;
        default: return Colors.grey.shade700;
      }
    }
  }
}