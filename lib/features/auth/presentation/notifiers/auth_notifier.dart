// Path: lib/features/auth/presentation/notifiers/auth_notifier.dart
import 'package:flutter/foundation.dart'; // Untuk ChangeNotifier
import 'package:appwrite/models.dart' as appwrite_models; // Alias untuk User model dari Appwrite

class AuthNotifier extends ChangeNotifier {
  appwrite_models.User? _currentUser; // Menyimpan data user yang sedang login
  bool _isLoggedIn = false;         // Menyimpan status login

  // Getter untuk mengakses data dari luar class
  appwrite_models.User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // Metode untuk mengupdate state saat user berhasil login
  void setUser(appwrite_models.User user) {
    _currentUser = user;
    _isLoggedIn = true;
    notifyListeners(); // Memberitahu widget yang "listen" bahwa ada perubahan state
    print('(AuthNotifier) User set: ${user.name}, LoggedIn: $_isLoggedIn');
  }

  // Metode untuk mengupdate state saat user logout atau sesi tidak valid
  void clearUser() {
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners(); // Memberitahu widget yang "listen"
    print('(AuthNotifier) User cleared, LoggedIn: $_isLoggedIn');
  }
}