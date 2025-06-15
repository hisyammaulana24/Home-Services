import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart';

import '../../../auth/presentation/notifiers/auth_notifier.dart';
import 'package:home_services/core/appwrite_client_service.dart';
import 'package:home_services/features/auth/presentation/screens/login_screen.dart';


class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;
  // bool _isProfileLoading = true; // Kita sederhanakan, data awal dari AuthNotifier

  // Konstanta Database & Koleksi (jika akan update ke DB Users)
  // static const String databaseId = 'YOUR_MAIN_DATABASE_ID';
  // static const String usersCollectionId = 'users';

  @override
  void initState() {
    super.initState();
    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.isLoggedIn && authNotifier.currentUser != null) {
      _nameController.text = authNotifier.currentUser!.name;
      // Untuk nomor telepon, kita akan biarkan kosong dulu jika dari DB belum berhasil
      // Jika Anda sudah berhasil mengambil dari DB Users di InitialCheckPage dan menyimpannya di AuthNotifier (misal di field custom),
      // Anda bisa isi _phoneController.text dari sana.
      // Untuk sekarang, kita fokus pada apa yang ada di Appwrite Auth.
      // _phoneController.text = authNotifier.currentUser?.prefs.data['phoneNumber'] ?? ''; // Jika Anda simpan di prefs
    }
    // setState(() { _isProfileLoading = false; });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfileName() async { // Fokus update nama di Auth dulu
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama tidak boleh kosong')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    final appwrite = context.read<AppwriteClientService>();
    final authNotifier = context.read<AuthNotifier>();

    try {
      // 1. Update nama di Appwrite Auth
      await appwrite.account.updateName(name: _nameController.text.trim());
      print('Nama di Appwrite Auth berhasil diupdate.');

      // 2. Dapatkan ulang data user dari Auth untuk refresh AuthNotifier
      final updatedUserFromAuth = await appwrite.account.get();
      authNotifier.setUser(updatedUserFromAuth);

      // TODO NANTI: Update juga nama di koleksi 'users' jika diperlukan sinkronisasi

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama berhasil diperbarui!')),
        );
      }
    } on AppwriteException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error update nama: ${e.message}')),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; });}
    }
  }


  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>(); // Gunakan watch untuk update UI

    // if (_isProfileLoading) { // Dihilangkan sementara
    //   return Scaffold(appBar: AppBar(title: const Text('Profil Saya')), body: const Center(child: CircularProgressIndicator()));
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: !authNotifier.isLoggedIn || authNotifier.currentUser == null
          ? const Center(child: Text('Silakan login untuk melihat profil.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    // controller: TextEditingController(text: authNotifier.currentUser!.email), // Lebih baik pakai initialValue jika readOnly
                    initialValue: authNotifier.currentUser!.email,
                    decoration: InputDecoration(
                      labelText: 'Email (Tidak bisa diubah)',
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                    readOnly: true,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Nomor Telepon (Belum disimpan)'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 32),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _updateProfileName, // Ubah ke _updateProfileName
                          child: const Text('Simpan Nama'),
                        ),
                  const SizedBox(height: 20),
                   ElevatedButton( // Tombol Logout
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
                    onPressed: () async {
                       final appwrite = context.read<AppwriteClientService>();
                       try {
                        await appwrite.account.deleteSession(sessionId: 'current');
                        context.read<AuthNotifier>().clearUser();
                        if (context.mounted) {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                            (route) => false,
                          );
                        }
                      } on AppwriteException catch (e) {
                         if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error Logout: ${e.message ?? "Terjadi kesalahan"}')),
                            );
                          }
                      }
                    },
                    child: const Text('Keluar Akun', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}