import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../main_navigation.dart';
import 'register_screen.dart';

/// Kelas ini merupakan widget stateful untuk menampilkan halaman login
class LoginScreen extends StatefulWidget {
  /// Konstruktor untuk membuat instance [LoginScreen]
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// State untuk kelas [LoginScreen] yang menangani logika form login
class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk menangkap teks yang diinput user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Method untuk mengirim data login ke server
  Future<void> _submitLogin() async {
    // Validasi input kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password tidak boleh kosong!')),
      );
      return;
    }

    // Memanggil provider
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      if (authProvider.user != null) {
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist(authProvider.user!.id);
      }
      // Pindah ke halaman Home jika berhasil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } else {
      // Tampilkan pesan error dari API
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Gagal login.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  /// Method untuk membersihkan resource saat widget dihapus
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  /// Method untuk merender tampilan antarmuka halaman login
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo dan Judul
                const Icon(Icons.spa, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                const Text(
                  'Welcome to Bloom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Serif',
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to discover curated lifestyle picks.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
                const SizedBox(height: 48),

                const Text('EMAIL', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _emailController,
                  hintText: 'your@email.com',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  forceLightMode: true,
                ),
                
                const SizedBox(height: 16),
                
                const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _passwordController,
                  hintText: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  isPassword: true,
                  forceLightMode: true,
                ),
                
                const SizedBox(height: 16),
                
                // Mengambil state loading dari AuthProvider
                Consumer<AuthProvider>(
                  builder: (context, auth, child) {
                    return CustomButton(
                      text: 'LOGIN',
                      isLoading: auth.isLoading,
                      onPressed: _submitLogin,
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: AppColors.textGrey)),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark),
                      ),
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