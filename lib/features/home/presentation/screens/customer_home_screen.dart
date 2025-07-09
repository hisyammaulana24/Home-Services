import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Jika Anda akan menggunakan provider di sini
import '../../../../../core/appwrite_client_service.dart'; // Sesuaikan path jika perlu akses Appwrite
import '../../../auth/presentation/screens/login_screen.dart'; // Untuk navigasi ke login setelah logout
import 'package:appwrite/appwrite.dart';
import '../../../auth/presentation/notifiers/auth_notifier.dart'; // Import AuthNotifier
import 'package:home_services/features/home/presentation/screens/customer_profile_screen.dart';
import 'package:home_services/features/services_catalogue/data/models/service_model.dart';
import 'package:home_services/features/services_catalogue/data/repositories/service_repository.dart';
import 'package:home_services/features/booking/presentation/screens/booking_form_screen.dart';
import 'package:home_services/features/booking/presentation/screens/customer_bookings_history_screen.dart'; // Tambahkan import ini

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  late Future<List<ServiceModel>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    // Ambil ServiceRepository dari Provider dan panggil getActiveServices
    // atau panggil Appwrite langsung jika tidak pakai repository
    final serviceRepository = context.read<ServiceRepository>();
    _servicesFuture = serviceRepository.getActiveServices();
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text(authNotifier.isLoggedIn && authNotifier.currentUser != null
            ? 'Beranda: ${authNotifier.currentUser!.name}'
            : 'Beranda Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_outlined),
            tooltip: 'Riwayat Pesanan',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CustomerBookingsHistoryScreen()),
              );
            },
          ),
          // ... (Tombol Profil dan Logout tetap sama) ...
           IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profil Saya',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CustomerProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              final appwrite = context.read<AppwriteClientService>();
              try {
                await appwrite.account.deleteSession(sessionId: 'current');
                context.read<AuthNotifier>().clearUser();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              } on AppwriteException catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal logout: ${e.message ?? 'Terjadi kesalahan'}')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Layanan Kami',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  print('Error FutureBuilder CustomerHomeScreen: ${snapshot.error}');
                  return Center(child: Text('Gagal memuat layanan: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Belum ada layanan yang tersedia saat ini.'));
                }

                final services = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16.0), // Padding bawah untuk list
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12.0),
                        // leading: service.imageUrl != null && service.imageUrl!.isNotEmpty
                        //     ? ClipRRect(
                        //         borderRadius: BorderRadius.circular(8.0),
                        //         child: Image.network(
                        //           service.imageUrl!,
                        //           width: 60, height: 60, fit: BoxFit.cover,
                        //           errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 50),
                        //         ),
                        //       )
                        //     : const Icon(Icons.cleaning_services, size: 50), // Placeholder icon
                        title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(service.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text('Harga: Rp ${service.basePrice.toStringAsFixed(0)}', style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w500)),
                              if (service.estimatedDuration != null && service.estimatedDuration!.isNotEmpty)
                                Text('Estimasi: ${service.estimatedDuration}'),
                            ],
                          ),
                        ),
                        isThreeLine: true, // Agar subtitle bisa lebih tinggi
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          print('Layanan dipilih: ${service.name} (ID: ${service.id})');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => BookingFormScreen(selectedService: service),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}