import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/booking/data/models/booking_model.dart';
import 'package:home_services/features/booking/data/repositories/booking_repository.dart';
import 'package:home_services/features/booking/presentation/screens/customer_booking_detail_screen.dart';

class CustomerBookingsHistoryScreen extends StatefulWidget {
  const CustomerBookingsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<CustomerBookingsHistoryScreen> createState() => _CustomerBookingsHistoryScreenState();
}

class _CustomerBookingsHistoryScreenState extends State<CustomerBookingsHistoryScreen> {
  late Future<List<BookingModel>> _bookingsFuture;
  
  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() {
    if (!mounted) return;

    final authNotifier = context.read<AuthNotifier>();
    
    if (authNotifier.isLoggedIn && authNotifier.currentUser != null) {
      final bookingRepository = context.read<BookingRepository>();
      setState(() {
        _bookingsFuture = bookingRepository.getMyBookings(authNotifier.currentUser!.$id);
      });
    } else {
      setState(() {
        _bookingsFuture = Future.error('Sesi pengguna tidak ditemukan. Silakan login kembali.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Riwayat Pesanan', style: TextStyle(fontSize: 18, color: Colors.white)),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.7),
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
                        child: Icon(Icons.history, size: 150, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadBookings,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Semua Pesanan Anda',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ),
          FutureBuilder<List<BookingModel>>(
            future: _bookingsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: colorScheme.error.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.error_outline,
                              size: 60,
                              color: colorScheme.error,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Gagal Memuat Data',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _loadBookings,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.history,
                            size: 60,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Belum Ada Riwayat',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Pesanan yang Anda buat akan muncul di sini',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final bookings = snapshot.data!;
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = bookings[index];
                    return _buildTimelineItem(booking, context, index, bookings.length);
                  },
                  childCount: bookings.length,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(BookingModel booking, BuildContext context, int index, int total) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final dateFormat = DateFormat('dd MMM yyyy');

    final isLast = index == total - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Indicator
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary,
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 100,
                  color: colorScheme.primary.withOpacity(0.3),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Booking Card
          Expanded(
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => CustomerBookingDetailScreen(booking: booking),
                    ),
                  ).then((didUpdate) {
                    if (didUpdate == true) _loadBookings();
                  });
                },
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
                              booking.servicesName ?? 'Layanan',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(booking.bookingStatus).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getStatusColor(booking.bookingStatus),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              booking.bookingStatus,
                              style: textTheme.labelLarge?.copyWith(
                                color: _getStatusColor(booking.bookingStatus),
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Service Info
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.cleaning_services, color: colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rp ${booking.totalPrice.toStringAsFixed(0)}',
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${dateFormat.format(booking.bookingDate)} • ${booking.bookingTimeSlot}',
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Timeline Footer
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: colorScheme.onSurface.withOpacity(0.6)),
                                const SizedBox(width: 8),
                                Text(
                                  dateFormat.format(booking.createdAt),
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Detail',
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(Icons.arrow_forward_ios, size: 14, color: colorScheme.primary),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING_ADMIN_CONFIRMATION': 
        return Colors.orange.shade700;
      case 'CONFIRMED': 
        return Colors.blue.shade700;
      case 'ASSIGNED_TO_CLEANER': 
        return Colors.lightBlue.shade700;
      case 'ONGOING': 
        return Colors.teal.shade700;
      case 'COMPLETED': 
        return Colors.green.shade700;
      case 'CANCELLED': 
        return Colors.red.shade700;
      case 'PAID': 
        return Colors.green.shade700;
      case 'PENDING_PAYMENT': 
        return Colors.orange.shade700;
      case 'FAILED': 
        return Colors.red.shade700;
      default: 
        return Colors.grey.shade700;
    }
  }
}