import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart'; // TAMBAHKAN IMPORT INI
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../splash_screen.dart'; // Untuk navigasi balik ke awal saat logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengisi data awal ke textfield jika user sudah login
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  void _handleLogout() async {
    // PERBAIKAN: Hanya bersihkan memori layar, data tetap aman di HP
    Provider.of<WishlistProvider>(context, listen: false).clearMemoryOnLogout();
    
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    // Mengganti tumpukan layar kembali ke splash/login screen
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile', style: TextStyle(fontFamily: 'Serif')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Bagian Avatar
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(
                user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 16),
            Text(user?.fullName ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Serif')),
            Text(user?.email ?? 'email@domain.com', style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 40),

            // Form Edit Profil
            Align(alignment: Alignment.centerLeft, child: const Text('EDIT PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey))),
            const SizedBox(height: 16),
            CustomTextField(controller: _nameController, hintText: 'Full Name', prefixIcon: Icons.person_outline),
            CustomTextField(controller: _phoneController, hintText: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            CustomButton(
              text: 'SAVE CHANGES',
              onPressed: () {
                // Panggil PUT /auth/profile lewat Provider
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fungsi update menyusul.')));
              },
            ),
            
            const SizedBox(height: 40),
            
            OutlinedButton.icon(
              onPressed: _handleLogout,
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text('LOGOUT', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            )
          ],
        ),
      ),
    );
  }
}