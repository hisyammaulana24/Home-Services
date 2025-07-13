import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:appwrite/appwrite.dart';
import 'package:home_services/features/booking/data/models/booking_model.dart';
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

  // Konstanta untuk Appwrite (disesuaikan dengan project Anda)
  static const String databaseId = '683f95e1003c6576571c';
  static const String bookingsCollectionId = 'bookings';
  static const String buktiPembayaranBucketId = 'bukti_pembayaran';

  @override
  void initState() {
    super.initState();
    _currentBooking = widget.booking;
  }

  Future<void> _pickAndUploadProof() async {
    final appwriteClientService = context.read<AppwriteClientService>();

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );

      if (result == null) return;

      setState(() { _isUploadingProof = true; });
      
      InputFile fileToUpload;
      final PlatformFile file = result.files.first;

      if (kIsWeb) {
        Uint8List? fileBytes = file.bytes;
        if (fileBytes == null) throw Exception("Failed to get file bytes");
        fileToUpload = InputFile.fromBytes(bytes: fileBytes, filename: file.name);
      } else {
        if (file.path == null) throw Exception("File path is null");
        fileToUpload = InputFile.fromPath(path: file.path!);
      }

      final uploadedFile = await appwriteClientService.storage.createFile(
        bucketId: buktiPembayaranBucketId,
        fileId: ID.unique(),
        file: fileToUpload,
      );
      
      await appwriteClientService.databases.updateDocument(
        databaseId: databaseId, 
        collectionId: bookingsCollectionId,
        documentId: _currentBooking.id,
        data: {
          'proofOfPaymentUrl': uploadedFile.$id,
          'paymentStatus': 'AWAITING_CONFIRMATION'
        }
      );

      await _refreshBookingData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diunggah!')),
        );
      }

    } on AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah bukti: ${e.message}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isUploadingProof = false; });
      }
    }
  }

  Future<void> _refreshBookingData() async {
    try {
      final appwriteClientService = context.read<AppwriteClientService>();
      final updatedDoc = await appwriteClientService.databases.getDocument(
        databaseId: databaseId,
        collectionId: bookingsCollectionId,
        documentId: _currentBooking.id,
      );
      
      if (mounted) {
        setState(() {
          _currentBooking = BookingModel.fromAppwriteDocument(updatedDoc);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui data: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isPendingPayment = _currentBooking.paymentStatus.toUpperCase() == 'PENDING_PAYMENT';
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Detail Pesanan',
                style: textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.1,
                        child: Icon(Icons.description, size: 150, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _refreshBookingData,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _currentBooking.servicesName ?? 'Layanan',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_currentBooking.bookingStatus).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(_currentBooking.bookingStatus),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  _currentBooking.bookingStatus,
                                  style: textTheme.labelLarge?.copyWith(
                                    color: _getStatusColor(_currentBooking.bookingStatus),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.payment, size: 20, color: colorScheme.onSurface.withOpacity(0.7)),
                              const SizedBox(width: 8),
                              Text(
                                'Status Pembayaran: ',
                                style: textTheme.bodyLarge,
                              ),
                              Text(
                                _currentBooking.paymentStatus,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(_currentBooking.paymentStatus, isPayment: true),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.attach_money, size: 20, color: colorScheme.onSurface.withOpacity(0.7)),
                              const SizedBox(width: 8),
                              Text(
                                'Total: ',
                                style: textTheme.bodyLarge,
                              ),
                              Text(
                                'Rp ${_currentBooking.totalPrice.toStringAsFixed(0)}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Card Detail Pesanan
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detail Pesanan',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.confirmation_number_outlined, 
                            'ID Pesanan', 
                            _currentBooking.id,
                          ),
                          _buildDetailRow(
                            Icons.calendar_today, 
                            'Tanggal Pesan', 
                            DateFormat('dd MMM yyyy, HH:mm').format(_currentBooking.createdAt),
                          ),
                          _buildDetailRow(
                            Icons.access_time, 
                            'Jadwal Layanan', 
                            '${DateFormat('dd MMM yyyy').format(_currentBooking.bookingDate)} (${_currentBooking.bookingTimeSlot})',
                          ),
                          _buildDetailRow(
                            Icons.location_on, 
                            'Alamat Layanan', 
                            _currentBooking.bookingAddrees,
                          ),
                          if (_currentBooking.notes != null && _currentBooking.notes!.isNotEmpty)
                            _buildDetailRow(
                              Icons.notes, 
                              'Catatan Tambahan', 
                              _currentBooking.notes!,
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Section Upload Bukti Pembayaran
                  if (isPendingPayment) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: Colors.orange.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Pembayaran Tertunda',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Silakan lakukan pembayaran dan unggah bukti transfer Anda untuk melanjutkan proses pesanan.',
                              style: textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 16),
                            _isUploadingProof
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Mengunggah bukti pembayaran...',
                                          style: textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ElevatedButton.icon(
                                  icon: const Icon(Icons.cloud_upload_outlined),
                                  label: const Text('Unggah Bukti Pembayaran'),
                                  onPressed: _pickAndUploadProof,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  // Status Pembayaran
                  if (!isPendingPayment) ...[
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      color: _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(
                              _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                                  ? Icons.hourglass_top_rounded
                                  : Icons.check_circle_outline,
                              color: _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                                  ? Colors.blue
                                  : Colors.green,
                              size: 40,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                                        ? 'Menunggu Konfirmasi'
                                        : 'Pembayaran Dikonfirmasi',
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                                          ? Colors.blue.shade700
                                          : Colors.green.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _currentBooking.paymentStatus.toUpperCase() == 'AWAITING_CONFIRMATION'
                                        ? 'Bukti pembayaran Anda sedang diverifikasi oleh tim kami'
                                        : 'Pembayaran Anda telah dikonfirmasi dan pesanan sedang diproses',
                                    style: textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status, {bool isPayment = false}) {
    if (isPayment) {
      switch (status.toUpperCase()) {
        case 'PENDING_PAYMENT': return Colors.orange.shade700;
        case 'AWAITING_CONFIRMATION': return Colors.blue.shade700;
        case 'PAID': return Colors.green.shade700;
        case 'FAILED': return Colors.red.shade700;
        default: return Colors.grey.shade700;
      }
    } else {
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