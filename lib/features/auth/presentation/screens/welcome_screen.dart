// lib/features/auth/presentation/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import 'login_screen.dart'; // Import LoginScreen
import 'register_screen.dart'; // Import RegisterScreen

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Latar Belakang Gambar
          Image.asset(
            'assets/images/login_bg.jpg', // Ganti dengan nama file gambar Anda
            fit: BoxFit.cover,
            // Tambahkan warna overlay agar teks lebih terbaca
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
          // Konten di atas gambar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Bersih, Cepat, Profesional.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pesan layanan kebersihan rumah terbaik hanya dengan beberapa ketukan.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 18,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                // Tombol Login
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                  child: const Text('Masuk', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(height: 16),
                // Tombol Daftar
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white, width: 2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                     Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: const Text('Daftar Akun Baru', style: TextStyle(fontSize: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}