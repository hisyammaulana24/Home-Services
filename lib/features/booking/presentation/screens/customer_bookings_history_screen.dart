import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal dan harga
import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/booking/data/models/booking_model.dart';
import 'package:home_services/features/booking/data/repositories/booking_repository.dart';
// Import halaman detail booking yang akan dibuat
// import 'customer_booking_detail_screen.dart';

// Tambahkan deklarasi StatefulWidget
class CustomerBookingsHistoryScreen extends StatefulWidget {
  const CustomerBookingsHistoryScreen({Key? key}) : super(key: key);

  @override
  _CustomerBookingsHistoryScreenState createState() => _CustomerBookingsHistoryScreenState();
}

class _CustomerBookingsHistoryScreenState extends State<CustomerBookingsHistoryScreen> {
  late Future<List<BookingModel>> _bookingsFuture;
  bool _isUserChecked = false; // Flag untuk menandakan pengecekan user awal selesai

  @override
  void initState() {
    super.initState();
    // Panggil _loadBookings setelah frame pertama selesai build untuk memastikan context.read aman
    // dan AuthNotifier mungkin sudah terupdate dari InitialCheckPage atau LoginScreen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    // Pastikan widget masih mounted sebelum melakukan operasi async atau setState
    if (!mounted) return;

    final authNotifier = context.read<AuthNotifier>();
    print('[HistoryScreen initState] Mengecek status login...');
    print('[HistoryScreen initState] authNotifier.isLoggedIn: ${authNotifier.isLoggedIn}');
    print('[HistoryScreen initState] authNotifier.currentUser ID: ${authNotifier.currentUser?.$id}'); // Gunakan ?. untuk safe access

    if (authNotifier.isLoggedIn && authNotifier.currentUser != null) {
      final bookingRepository = context.read<BookingRepository>();
      print('[HistoryScreen initState] Mengambil bookings untuk User ID: ${authNotifier.currentUser!.$id}');
      setState(() {
        _bookingsFuture = bookingRepository.getMyBookings(authNotifier.currentUser!.$id);
        _isUserChecked = true; // Pengecekan user selesai, data (atau error) akan diambil
      });
    } else {
      print('[HistoryScreen initState] Tidak ada pengguna yang login atau currentUser null.');
      setState(() {
        _bookingsFuture = Future.error(Exception('Sesi pengguna tidak ditemukan untuk memuat riwayat.'));
        _isUserChecked = true; // Pengecekan user selesai, hasilnya error
      });
    }
  }

  // ... (build method dan _getStatusColor tetap sama) ...
  @override
  Widget build(BuildContext context) {
    // Kita tidak perlu lagi watch AuthNotifier di sini jika pengambilan data hanya sekali di initState
    // final authNotifier = context.watch<AuthNotifier>(); 

    // Tampilkan loading global sampai _loadBookings selesai melakukan pengecekan awal
    if (!_isUserChecked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Riwayat Pesanan Saya')),
        body: const Center(child: CircularProgressIndicator(semanticsLabel: 'Memeriksa pengguna...')),
      );
    }

    // Setelah _isUserChecked true, kita bisa menggunakan FutureBuilder
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan Saya'),
      ),
      body: FutureBuilder<List<BookingModel>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          // ... (logika FutureBuilder tetap sama seperti sebelumnya) ...
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('[HistoryScreen FutureBuilder] Error: ${snapshot.error}');
            return Center(child: Text('Gagal memuat riwayat pesanan: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Anda belum memiliki riwayat pesanan.'));
          }

          final bookings = snapshot.data!;
          return ListView.builder(
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
                        Text('Tanggal Pesan: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(booking.createdAt)}'),
                        Text('Jadwal Layanan: ${DateFormat('dd MMM yyyy', 'id_ID').format(booking.bookingDate)} (${booking.bookingTimeSlot})'),
                        const SizedBox(height: 4),
                        Text('Status Pesanan: ${booking.bookingStatus}', 
                             style: TextStyle(fontWeight: FontWeight.w500, color: _getStatusColor(booking.bookingStatus))),
                        Text('Status Pembayaran: ${booking.paymentStatus}',
                             style: TextStyle(color: _getStatusColor(booking.paymentStatus, isPayment: true))),
                        Text('Total: Rp ${NumberFormat("#,##0", "id_ID").format(booking.totalPrice)}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navigasi ke Halaman Detail Booking
                    print('Booking dipilih: ${booking.id}');
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Detail untuk booking ${booking.id} belum dibuat')),
                     );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status, {bool isPayment = false}) {
    // ... (fungsi _getStatusColor tetap sama) ...
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