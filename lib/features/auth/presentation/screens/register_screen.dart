import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/appwrite.dart'; // Untuk ID.unique() dan AppwriteException
import '../../../../core/appwrite_client_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Konfirmasi password tidak cocok!')),
          );
        }
        return;
      }
      setState(() {
        _isLoading = true;
      });

      final appwrite = context.read<AppwriteClientService>();
      const String databaseId = '683f95e1003c6576571c'; // PASTIKAN INI BENAR
      const String usersCollectionId = 'users'; // PASTIKAN INI BENAR

      try {
        print('[REGISTER] Mencoba membuat akun Auth...');
        // Langkah 1: Buat akun di Appwrite Auth
        final authUser = await appwrite.account.create(
          // <-- INI YANG BENAR UNTUK MEMBUAT AKUN AUTH
          userId: ID.unique(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          name: _nameController.text.trim(),
        );
        // Jika baris ini tercapai, berarti authUser dari account.create() valid
        print(
            '[REGISTER] Akun Auth berhasil dibuat. User ID: ${authUser.$id}, Name: ${authUser.name}');

        print('[REGISTER] Mencoba membuat dokumen di koleksi users...');
        print('[REGISTER] Database ID: $databaseId');
        print('[REGISTER] Collection ID: $usersCollectionId');
        print('[REGISTER] Document ID (dari authUser.\$id): ${authUser.$id}');
        final dataToCreate = {
          'name': authUser.name, // Sekarang authUser.name valid
          'role': 'customer',
        };
        print('[REGISTER] Data yang akan dikirim: $dataToCreate');

        // Langkah 2: Buat dokumen di koleksi 'users' di Database
        await appwrite.databases.createDocument(
          databaseId: databaseId,
          collectionId: usersCollectionId,
          documentId: authUser
              .$id, // Gunakan ID dari authUser yang didapat dari account.create()
          data: dataToCreate,
          // Untuk tes awal, kita hilangkan parameter 'permissions:' dulu
          // Jika ini berhasil, baru kita tambahkan lagi Document Level Permissions
        );
        print(
            '[REGISTER] Dokumen di koleksi "users" BERHASIL dibuat untuk ID: ${authUser.$id}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Registrasi berhasil! Silakan login.')),
          );
          Navigator.of(context)
              .pop(); // Kembali ke halaman Login setelah registrasi
        }
      } on AppwriteException catch (e) {
        print('--- [REGISTER] ERROR APPWRITE EXCEPTION ---');
        print('Pesan Error: ${e.message}');
        print('Kode Error: ${e.code}');
        print('Tipe Error: ${e.type}');
        print('Respons Lengkap Error: ${e.response}');
        print('-------------------------------------------');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Error Registrasi: ${e.message ?? "Terjadi kesalahan"}')),
          );
        }
      } catch (e, stacktrace) {
        print('--- [REGISTER] ERROR UMUM (NON-APPWRITE) ---');
        print('Error: $e');
        print('Stacktrace: $stacktrace');
        print('---------------------------------------------');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error tidak diketahui: $e')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Akun Baru')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Bergabung dengan Kami!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person)),
                  validator: (value) => (value == null || value.isEmpty)
                      ? 'Nama tidak boleh kosong'
                      : null,
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email)),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!value.contains('@')) return 'Format email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock_outline)),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Password tidak boleh kosong';
                    if (value.length < 8) return 'Password minimal 8 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                      labelText: 'Konfirmasi Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock)),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty)
                      return 'Konfirmasi password tidak boleh kosong';
                    if (value != _passwordController.text)
                      return 'Password tidak cocok';
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            textStyle: const TextStyle(fontSize: 16.0)),
                        onPressed: _isLoading ? null : _registerUser,
                        child: const Text('Daftar'),
                      ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah punya akun?'),
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        } else {
                          Navigator.of(context).pushReplacementNamed('/login');
                        }
                      },
                      child: const Text('Masuk di sini'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
