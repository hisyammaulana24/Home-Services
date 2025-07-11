// Path: lib/features/booking/presentation/screens/customer_bookings_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/booking/data/models/booking_model.dart';
import 'package:home_services/features/booking/data/repositories/booking_repository.dart';
// Import halaman detail booking
import 'package:home_services/features/booking/presentation/screens/customer_booking_detail_screen.dart'; // Pastikan path ini benar


class CustomerBookingsHistoryScreen extends StatefulWidget {
  const CustomerBookingsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CustomerBookingsHistoryScreen> createState() => _CustomerBookingsHistoryScreenState();
}

class _CustomerBookingsHistoryScreenState extends State<CustomerBookingsHistoryScreen> {
  late Future<List<BookingModel>> _bookingsFuture;
  
  // Flag ini tidak lagi terlalu dibutuhkan jika kita langsung set Future di initState dan handle di FutureBuilder
  // bool _isUserChecked = false; 

  @override
  void initState() {
    super.initState();
    // Panggil _loadBookings sekali di initState untuk menginisialisasi Future
    _loadBookings();
  }

  // Fungsi untuk memuat atau me-refresh data booking
  void _loadBookings() {
    // Pastikan context masih valid sebelum digunakan
    if (!mounted) return;

    final authNotifier = context.read<AuthNotifier>();
    
    if (authNotifier.isLoggedIn && authNotifier.currentUser != null) {
      final bookingRepository = context.read<BookingRepository>();
      print('[HistoryScreen] Mengambil bookings untuk User ID: ${authNotifier.currentUser!.$id}');
      // Set state untuk _bookingsFuture agar FutureBuilder bisa me-rebuild
      setState(() {
        _bookingsFuture = bookingRepository.getMyBookings(authNotifier.currentUser!.$id);
      });
    } else {
      print('[HistoryScreen] Tidak ada pengguna yang login atau currentUser null.');
      // Set _bookingsFuture ke Future yang sudah selesai dengan error
      setState(() {
        _bookingsFuture = Future.error(Exception('Sesi pengguna tidak ditemukan untuk memuat riwayat.'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan Saya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _loadBookings, // Tombol refresh memanggil _loadBookings lagi
          ),
        ],
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('[HistoryScreen FutureBuilder] Error: ${snapshot.error}');
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Gagal memuat riwayat pesanan: ${snapshot.error}', textAlign: TextAlign.center),
              )
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat pesanan.'));
          }

          final bookings = snapshot.data!;
          return RefreshIndicator( // Tambahkan RefreshIndicator untuk pull-to-refresh
            onRefresh: () async {
              _loadBookings();
            },
            child: ListView.builder(
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16.0),
                    title: Text(booking.servicesName ?? 'Layanan Tidak Diketahui', 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tanggal Pesan: ${DateFormat('dd MMM yyyy, HH:mm').format(booking.createdAt)}'),
                          Text('Jadwal Layanan: ${DateFormat('dd MMM yyyy').format(booking.bookingDate)} (${booking.bookingTimeSlot})'),
                          const SizedBox(height: 4),
                          Text('Status Pesanan: ${booking.bookingStatus}', 
                               style: TextStyle(fontWeight: FontWeight.w500, color: _getStatusColor(booking.bookingStatus))),
                          Text('Status Pembayaran: ${booking.paymentStatus}',
                               style: TextStyle(color: _getStatusColor(booking.paymentStatus, isPayment: true))),
                          Text('Total: Rp ${booking.totalPrice.toStringAsFixed(0)}'),
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // --- PERUBAHAN UTAMA DI SINI ---
                      // Navigasi ke Halaman Detail Booking dan tunggu hasilnya
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CustomerBookingDetailScreen(booking: booking),
                        ),
                      ).then((didUpdate) {
                        // 'then' akan dieksekusi setelah halaman detail ditutup (pop)
                        // Jika ada perubahan di halaman detail, kita bisa me-refresh halaman ini
                        if (didUpdate == true) {
                          print('[HistoryScreen] Kembali dari detail, me-refresh riwayat...');
                          _loadBookings();
                        }
                      });
                      // ------------------------------
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status, {bool isPayment = false}) {
    // Fungsi ini tetap sama, tidak perlu diubah
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