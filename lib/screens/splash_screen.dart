import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../utils/constants.dart';
import 'auth/login_screen.dart';
import 'main_navigation.dart';

/// [SplashScreen] adalah layar pertama yang dilihat user saat membuka aplikasi.
class SplashScreen extends StatefulWidget {
  /// Konstruktor untuk membuat instance [SplashScreen]
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

/// State untuk kelas [SplashScreen] yang menangani logika pengecekan login
class _SplashScreenState extends State<SplashScreen> {
  
  @override
  /// Method ini dipanggil saat widget pertama kali diinisialisasi
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  /// Fungsi untuk mengecek apakah user sudah pernah login sebelumnya
  Future<void> _checkLoginStatus() async {
    // Memberikan jeda waktu 2.5 detik agar logo terlihat
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;

    // Memanggil fungsi tryAutoLogin dari AuthProvider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuth = await authProvider.tryAutoLogin();

    if (!mounted) return;

    if (isAuth) {
      if (authProvider.user != null) {
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist(authProvider.user!.id);
      }
      // Jika token ada dan valid, langsung ke Main Navigation (Home)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      // Jika belum login, arahkan ke layar Login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  /// Method untuk merender tampilan antarmuka splash screen
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ikon Bunga 
            const Icon(
              Icons.spa,
              size: 60,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            // Teks "Bloom" sesuai nama aplikasi
            const Text(
              'Bloom',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
                fontFamily: 'Serif', 
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}