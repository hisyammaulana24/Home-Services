import 'package:flutter/material.dart';
import 'package:home_services/features/home/presentation/screens/customer_home_screen.dart';
import 'package:provider/provider.dart';
import '../../../../core/appwrite_client_service.dart'; // Sesuaikan path jika perlu
import 'package:appwrite/appwrite.dart';
import '../notifiers/auth_notifier.dart'; // Untuk ID.unique() dan AppwriteException
// import 'register_screen.dart'; // Akan di-uncomment saat register_screen.dart siap

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginUser() async {
  if (_formKey.currentState!.validate()) {
    setState(() { _isLoading = true; });

    final appwrite = context.read<AppwriteClientService>();
    final authNotifier = context.read<AuthNotifier>(); // Ambil AuthNotifier

    try {
      await appwrite.account.createEmailSession( // session tidak perlu disimpan di sini
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      final user = await appwrite.account.get(); // Dapatkan data user setelah sesi dibuat
      print('Login berhasil: ${user.name}');
      
      authNotifier.setUser(user); // <<-- UPDATE STATE DI NOTIFIER

      if (mounted) {
        // Navigasi ke rute awal aplikasi, yang akan menjalankan InitialCheckPage asli
        // dan InitialCheckPage akan mengarahkan ke CustomerHomeScreen karena user sudah di-set
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const CustomerHomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } on AppwriteException catch (e) {
      // ... (error handling tetap sama) ...
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error Login: ${e.message ?? "Email atau password salah"}')),
        );
      }
    } catch (e) {
      // ... (error handling tetap sama) ...
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error tidak diketahui: $e')),
        );
      }
    } finally {
      if (mounted) { setState(() { _isLoading = false; });}
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masuk Akun')),
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
                  'Selamat Datang Kembali!',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32.0),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password tidak boleh kosong';
                    }
                    if (value.length < 8) { // Appwrite default
                      return 'Password minimal 8 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8.0),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Navigasi ke halaman Lupa Password
                      print('Lupa Password ditekan');
                    },
                    child: const Text('Lupa Password?'),
                  ),
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          textStyle: const TextStyle(fontSize: 16.0),
                        ),
                        onPressed: _isLoading ? null : _loginUser, // Nonaktifkan tombol saat loading
                        child: const Text('Masuk'),
                      ),
                const SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum punya akun?'),
                    TextButton(
                      onPressed: () {
                        // Pastikan rute '/register' sudah ada di main.dart
                        Navigator.of(context).pushNamed('/register');
                      },
                      child: const Text('Daftar di sini'),
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