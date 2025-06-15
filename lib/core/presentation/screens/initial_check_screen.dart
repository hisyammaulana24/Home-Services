// lib/core/presentation/screens/initial_check_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart'; // Untuk AppwriteException

// Sesuaikan path ini ke AppwriteClientService Anda
import '../../appwrite_client_service.dart'; // Pastikan path ini benar sesuai struktur folder Anda

// Impor halaman login dan halaman home customer
import '../../../features/auth/presentation/screens/login_screen.dart';
// Anda akan membuat file CustomerHomeScreen nanti
import '../../../features/home/presentation/screens/customer_home_screen.dart';

import '../../../features/auth/presentation/notifiers/auth_notifier.dart';

// CLASS INITIALCHECKPAGE YANG SUDAH ADA DI main.dart ANDA DIPINDAHKAN KE SINI
class InitialCheckPage extends StatefulWidget {
  const InitialCheckPage({super.key});
  @override
  State<InitialCheckPage> createState() => _InitialCheckPageState();
}

class _InitialCheckPageState extends State<InitialCheckPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
  final appwrite = context.read<AppwriteClientService>();
  final authNotifier = context.read<AuthNotifier>(); // Ambil AuthNotifier

  try {
    final user = await appwrite.account.get();
    print('(InitialCheckScreen Asli) Pengguna sudah login: ${user.name} (${user.email})');
    
    authNotifier.setUser(user); // <<-- UPDATE STATE DI NOTIFIER

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
      );
    }
  } on AppwriteException catch (e) {
    print('(InitialCheckScreen Asli) Belum login: ${e.message}');
    
    authNotifier.clearUser(); // <<-- UPDATE STATE DI NOTIFIER

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  } catch (e) {
    print('(InitialCheckScreen Asli) Error: $e');
    
    authNotifier.clearUser(); // <<-- UPDATE STATE DI NOTIFIER (sebagai fallback)

     if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error initial check: $e')),
      );
       Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
       );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Memuat aplikasi...'),
          ],
        ),
      ),
    );
  }
}