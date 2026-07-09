import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Kelas Provider untuk mengelola pengaturan tema aplikasi (gelap/terang).
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  
  /// Mengembalikan status true jika tema saat ini adalah mode gelap (dark mode).
  bool get isDarkMode => _isDarkMode;

  /// Konstruktor [ThemeProvider] yang akan otomatis memuat preferensi tema saat diinisialisasi.
  ThemeProvider() {
    _loadTheme();
  }

  /// Method untuk mengubah (toggle) antara tema terang dan tema gelap.
  /// Juga menyimpan preferensi ini secara lokal menggunakan [SharedPreferences].
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  /// Method privat untuk memuat status tema (mode gelap atau terang) dari [SharedPreferences].
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}