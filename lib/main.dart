import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import utama
import 'package:home_services/core/appwrite_client_service.dart';
import 'package:home_services/features/auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/features/services_catalogue/data/repositories/service_repository.dart';
import 'package:home_services/features/booking/data/repositories/booking_repository.dart';

// Import Halaman/Screen
import 'package:home_services/core/presentation/screens/initial_check_screen.dart'; 
import 'package:home_services/features/auth/presentation/screens/welcome_screen.dart'; // <-- IMPORT BARU
import 'package:home_services/features/auth/presentation/screens/login_screen.dart';
import 'package:home_services/features/auth/presentation/screens/register_screen.dart';
import 'package:home_services/features/home/presentation/screens/customer_home_screen.dart';


void main() async {
  // 1. Pastikan Flutter binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Buat instance dan inisialisasi AppwriteClientService
  final AppwriteClientService appwriteClientInstance = AppwriteClientService();
  try {
    await appwriteClientInstance.init();
    print("Inisialisasi Appwrite Client BERHASIL.");
  } catch (e) {
    print("GAGAL Inisialisasi Appwrite Client: $e");
  }

  // 3. Jalankan aplikasi dengan MultiProvider
  runApp(
    MultiProvider(
      providers: [
        Provider<AppwriteClientService>.value(value: appwriteClientInstance),
        ChangeNotifierProvider<AuthNotifier>(create: (_) => AuthNotifier()),
        ProxyProvider<AppwriteClientService, ServiceRepository>(
          update: (_, appwriteService, __) => ServiceRepository(appwriteService),
        ),
        ProxyProvider<AppwriteClientService, BookingRepository>(
          update: (_, appwriteService, __) => BookingRepository(appwriteService),
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
      // Nonaktifkan banner Debug
      debugShowCheckedModeBanner: false, 
      title: 'Home Services App',
      theme: ThemeData(
        // Tema modern dengan warna primer
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
        // Kustomisasi tema tombol dan input
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          )
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade100,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        )
      ),
      
      // Halaman awal aplikasi akan selalu `InitialCheckPage`
      home: const InitialCheckPage(), 
      
      // Definisikan semua rute yang bisa dinavigasi dengan nama
      routes: {
        '/welcome': (context) => const WelcomeScreen(), // <-- RUTE BARU
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/customer_home': (context) => const CustomerHomeScreen(), 
      },
    );
  }
}