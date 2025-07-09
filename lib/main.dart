import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/appwrite_client_service.dart';
import 'features/auth/presentation/notifiers/auth_notifier.dart';
import 'core/presentation/screens/initial_check_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/customer_home_screen.dart';
import 'package:home_services/features/services_catalogue/data/repositories/service_repository.dart';
import 'package:home_services/features/booking/data/repositories/booking_repository.dart';

void main() async {
  // 1. Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. HAPUS atau KOMENTARI Bagian Inisialisasi Format Tanggal Ini:
  // try {
  //   await initializeDateFormatting('id_ID', null);
  //   print('Inisialisasi format tanggal id_ID BERHASIL.');
  // } catch (e) {
  //   print('GAGAL inisialisasi format tanggal id_ID: $e');
  // }

  // 3. Buat instance dan inisialisasi AppwriteClientService
  final AppwriteClientService appwriteClientInstance = AppwriteClientService();
  try {
    await appwriteClientInstance.init();
    print("Inisialisasi Appwrite Client BERHASIL.");
  } catch (e) {
    print("GAGAL Inisialisasi Appwrite Client: $e");
  }

  // 4. Jalankan aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [
        Provider<AppwriteClientService>.value(value: appwriteClientInstance),
        ChangeNotifierProvider<AuthNotifier>(create: (_) => AuthNotifier()),
        ProxyProvider<AppwriteClientService, ServiceRepository>(
          update: (_, appwriteService, __) =>
              ServiceRepository(appwriteService),
        ),
        ProxyProvider<AppwriteClientService, BookingRepository>(
          update: (_, appwriteService, __) =>
              BookingRepository(appwriteService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Services App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      // --- HAPUS ATAU KOMENTARI KONFIGURASI LOKALISASI DI SINI ---
      // localizationsDelegates: const [
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('id', 'ID'),
      // ],
      // locale: const Locale('id', 'ID'),
      // ----------------------------------------------------

      home: const InitialCheckPage(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(),
      },
    );
  }
}
