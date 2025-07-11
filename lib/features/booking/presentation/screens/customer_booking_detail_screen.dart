// Path: lib/features/booking/presentation/screens/customer_booking_detail_screen.dart

// Import untuk 'kIsWeb' (deteksi platform web)
import 'package:flutter/foundation.dart' show kIsWeb; 
// Import dart:io hanya jika BUKAN web (meskipun image_picker menanganinya, ini praktik yang baik jika Anda perlu)
// Untuk sekarang, kita tidak perlu import 'dart:io' secara eksplisit karena image_picker yang akan menanganinya
// dan kita akan memblokir fungsinya di web.
// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk Clipboard
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appwrite/appwrite.dart';

import 'package:home_services/features/booking/data/models/booking_model.dart';
// Hapus import untuk BookingRepository karena kita akan panggil Appwrite langsung untuk kesederhanaan
// import 'package:home_services/features/booking/data/repositories/booking_repository.dart';
import 'package:home_services/core/appwrite_client_service.dart';

class CustomerBookingDetailScreen extends StatefulWidget {
  final BookingModel booking;

  const CustomerBookingDetailScreen({super.key, required this.booking});

  @override
  State<CustomerBookingDetailScreen> createState() => _CustomerBookingDetailScreenState();
}

class _CustomerBookingDetailScreenState extends State<CustomerBookingDetailScreen> {
  bool _isUploadingProof = false;
  late BookingModel _currentBooking; 

  // Definisikan ID Database, Koleksi, dan Bucket di sini agar mudah diubah
  // GANTI DENGAN ID ANDA YANG SEBENARNYA!
  static const String _databaseId = '683f95e1003c6576571c'; 
  static const String _bookingsCollectionId = 'bookings';
  static const String _buktiPembayaranBucketId = 'bukti_pembayaran';


  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  // Fungsi untuk memilih gambar dan mengunggahnya
  Future<void> _pickAndUploadProof() async {
    // --- PENGECEKAN PLATFORM WEB UNTUK MENGHINDARI ERROR dart:io ---
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload file tidak didukung pada versi web saat ini.')),
        );
      }
      return; // Hentikan eksekusi jika di web
    }
    // -----------------------------------------------------------------

    final ImagePicker picker = ImagePicker();
    final appwriteClientService = context.read<AppwriteClientService>();

    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70); // imageQuality untuk kompresi
      if (image == null) {
        print('Tidak ada gambar yang dipilih.');
        return; 
      }

      setState(() { _isUploadingProof = true; });

      final fileToUpload = await InputFile.fromPath(
        path: image.path,
        filename: 'bukti_${_currentBooking.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final uploadedFile = await appwriteClientService.storage.createFile(
            bucketId: _buktiPembayaranBucketId, // Gunakan konstanta
            fileId: ID.unique(),
            file: fileToUpload,
          );
      
      print('File berhasil diupload, File ID: ${uploadedFile.$id}');

      // Update dokumen booking di database dengan fileId yang baru
      await appwriteClientService.databases.updateDocument(
          databaseId: _databaseId, 
          collectionId: _bookingsCollectionId,
          documentId: _currentBooking.id,
          data: {
            'proofOfPaymentUrl': uploadedFile.$id, // Simpan ID file
            'paymentStatus': 'AWAITING_CONFIRMATION'
          });

      // Refresh halaman dengan data booking yang baru
      await _refreshBookingData(); // Tambahkan await agar loading indicator menunggu refresh selesai

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diunggah!')),
        );
        // Kita tidak pop() di sini agar pengguna bisa melihat status barunya.
        // Tombol kembali di AppBar sudah cukup.
      }

    } on AppwriteException catch (e) {
      print('Error saat upload bukti: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah bukti: ${e.message}')),
        );
      }
    } catch (e) {
      print('Error umum saat upload bukti: $e');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terjadi kesalahan tidak diketahui.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isUploadingProof = false; });
      }
    }
  }

  // Fungsi untuk mengambil ulang data booking dari server
  Future<void> _refreshBookingData() async {
    try {
      final appwriteClientService = context.read<AppwriteClientService>();
      final updatedDoc = await appwriteClientService.databases.getDocument(
        databaseId: _databaseId,
        collectionId: _bookingsCollectionId,
        documentId: _currentBooking.id,
      );
      if (mounted) {
        setState(() {
          _currentBooking = BookingModel.fromAppwriteDocument(updatedDoc);
        });
      }
    } catch (e) {
      print('Gagal me-refresh data booking: $e');
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan #${_currentBooking.id.substring(0, 8)}...'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
            onPressed: _refreshBookingData,
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshBookingData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_currentBooking.servicesName ?? 'Layanan Tidak Diketahui', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              _buildDetailRow('ID Pesanan', _currentBooking.id),
              _buildDetailRow('Tanggal Pesan', DateFormat('dd MMM yyyy, HH:mm').format(_currentBooking.createdAt)),
              _buildDetailRow('Jadwal Layanan', '${DateFormat('dd MMM yyyy').format(_currentBooking.bookingDate)} (${_currentBooking.bookingTimeSlot})'),
              _buildDetailRow('Alamat Layanan', _currentBooking.bookingAddrees),
              if (_currentBooking.notes != null && _currentBooking.notes!.isNotEmpty)
                _buildDetailRow('Catatan Tambahan', _currentBooking.notes),
              const Divider(height: 32, thickness: 1),
              _buildDetailRow('Status Pesanan', _currentBooking.bookingStatus, valueStyle: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(_currentBooking.bookingStatus))),
              _buildDetailRow('Status Pembayaran', _currentBooking.paymentStatus, valueStyle: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(_currentBooking.paymentStatus, isPayment: true))),
              _buildDetailRow('Total Pembayaran', 'Rp ${_currentBooking.totalPrice.toStringAsFixed(0)}', valueStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 24),

              // Bagian Upload Bukti Pembayaran (muncul jika status PENDING_PAYMENT)
              if (_currentBooking.paymentStatus.toUpperCase() == 'PENDING_PAYMENT')
                _buildUploadSection(),
              
              if (_currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Bukti pembayaran Anda sedang menunggu konfirmasi Admin.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade700)),
                ),
              
              if (_currentBooking.paymentStatus.toUpperCase() == 'PAID')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text('Pembayaran Anda sudah dikonfirmasi.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Pisahkan UI upload ke dalam fungsi helper agar build method lebih rapi
  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Pembayaran Anda masih tertunda.', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
        const SizedBox(height: 8),
        const Text('Silakan lakukan pembayaran dan unggah bukti Anda di sini.'),
        const SizedBox(height: 16),
        // Sembunyikan tombol di web, tampilkan pesan
        if (kIsWeb)
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Text(
              'Fitur upload bukti hanya tersedia di aplikasi Android.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          )
        else // Tampilkan tombol upload jika bukan web
          _isUploadingProof
            ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()))
            : ElevatedButton.icon(
                icon: const Icon(Icons.upload_file_outlined),
                label: const Text('Unggah Bukti Pembayaran'),
                onPressed: _pickAndUploadProof,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
      ],
    );
  }
  
  // Fungsi helper untuk baris detail
  Widget _buildDetailRow(String label, String? value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  // Fungsi helper untuk warna status
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