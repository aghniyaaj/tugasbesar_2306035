import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../splash_screen.dart';

/// Kelas ini merupakan layar untuk menampilkan profil pengguna dan pengaturannya.
class ProfileScreen extends StatefulWidget {
  // Fungsi yang diterima dari Main Navigation untuk pindah antar tab
  final VoidCallback? onNavigateToWishlist;
  final VoidCallback? onNavigateToOrders;

  /// Konstruktor untuk membuat [ProfileScreen].
  const ProfileScreen({
    Key? key, 
    this.onNavigateToWishlist, 
    this.onNavigateToOrders
  }) : super(key: key);

  /// Method untuk membuat state dari [ProfileScreen].
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

/// State untuk [ProfileScreen].
class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  /// Method untuk inisialisasi state dengan data pengguna.
  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _avatarController.text = user.avatarUrl ?? '';
    }
  }

  /// Method untuk memproses logout pengguna.
  void _handleLogout() async {
    Provider.of<WishlistProvider>(context, listen: false).clearMemoryOnLogout();
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (Route<dynamic> route) => false,
    );
  }

  /// Method untuk membangun UI layar profil.
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;
    
    // Warna Dinamis: Mengecek apakah sedang Dark Mode atau Light Mode
    final isDark = themeProvider.isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      // INI KUNCI DARK MODE: Mengikuti warna background dari ThemeData di main.dart
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      
      appBar: AppBar(
        title: Text('My Profile', style: TextStyle(fontFamily: 'Serif', color: textColor)),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Agar menyatu dengan background
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // --- HEADER: AVATAR & NAME ---
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: hasAvatar ? NetworkImage(user!.avatarUrl!) : null,
              child: !hasAvatar
                  ? Text(user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary))
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'User', 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Serif')
            ),
            const SizedBox(height: 32),

            // --- SECTION: EDIT PROFILE ---
            Align(
              alignment: Alignment.centerLeft, 
              child: Text('EDIT PROFILE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey.withOpacity(0.8), letterSpacing: 1))
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  CustomTextField(controller: _nameController, hintText: 'Full Name', prefixIcon: Icons.person_outline),
                  CustomTextField(controller: _phoneController, hintText: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
                  CustomTextField(controller: _avatarController, hintText: 'Avatar Image URL', prefixIcon: Icons.image_outlined),
                  const SizedBox(height: 8),
                  Consumer<AuthProvider>(
                    builder: (context, auth, child) {
                      return CustomButton(
                        text: 'SAVE CHANGES',
                        isLoading: auth.isLoading,
                        onPressed: () async {
                          final success = await auth.updateProfile(
                            _nameController.text.trim(),
                            _phoneController.text.trim(),
                            _avatarController.text.trim(),
                          );
                          if (!mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil berhasil diupdate! ✨'), backgroundColor: Colors.green));
                          }
                        },
                      );
                    }
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // --- SECTION: SETTINGS ---
            Align(
              alignment: Alignment.centerLeft, 
              child: Text('SETTINGS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textGrey.withOpacity(0.8), letterSpacing: 1))
            ),
            const SizedBox(height: 12),
            
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Toggle Dark Mode
                  SwitchListTile(
                    title: Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                    secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: AppColors.primary),
                    value: isDark,
                    activeColor: AppColors.primary,
                    onChanged: (value) => themeProvider.toggleTheme(),
                  ),
                  Divider(color: borderColor, height: 1),
                  
                  // My Wishlist (Navigasi Pindah Tab)
                  ListTile(
                    leading: const Icon(Icons.favorite_border, color: AppColors.textGrey),
                    title: Text('My Wishlist', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
                    onTap: widget.onNavigateToWishlist, // Menggunakan fungsi dari Main Navigation
                  ),
                  Divider(color: borderColor, height: 1),
                  
                  // My Orders (Navigasi Pindah Tab)
                  ListTile(
                    leading: const Icon(Icons.inventory_2_outlined, color: AppColors.textGrey),
                    title: Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textGrey),
                    onTap: widget.onNavigateToOrders, // Menggunakan fungsi dari Main Navigation
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // --- SECTION: LOGOUT ---
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.shade50,
                side: BorderSide.none, 
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}