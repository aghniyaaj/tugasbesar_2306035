import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/wishlist_provider.dart'; 
import '../../utils/constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';
import '../splash_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Mengisi data awal ke textfield jika user sudah login
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      _nameController.text = user.fullName;
      _phoneController.text = user.phoneNumber ?? '';
      _avatarController.text = user.avatarUrl ?? '';
    }
  }

  void _handleLogout() async {
    Provider.of<WishlistProvider>(context, listen: false).clearMemoryOnLogout();
    await Provider.of<AuthProvider>(context, listen: false).logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final bool hasAvatar = user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Profile', style: TextStyle(fontFamily: 'Serif')), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Bagian Avatar (Sekarang mendukung Gambar!)
            CircleAvatar(
              radius: 45,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              backgroundImage: hasAvatar ? NetworkImage(user!.avatarUrl!) : null,
              onBackgroundImageError: hasAvatar ? (exception, stackTrace) => {} : null,
              child: !hasAvatar
                  ? Text(
                      user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primary),
                    )
                  : null, // Kosongkan text jika gambar ada
            ),
            const SizedBox(height: 16),
            Text(user?.fullName ?? 'User', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark, fontFamily: 'Serif')),
            Text(user?.email ?? 'email@domain.com', style: const TextStyle(color: AppColors.textGrey)),
            const SizedBox(height: 40),

            // Form Edit Profil
            const Align(alignment: Alignment.centerLeft, child: Text('EDIT PROFILE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey))),
            const SizedBox(height: 16),
            
            CustomTextField(controller: _nameController, hintText: 'Full Name', prefixIcon: Icons.person_outline),
            CustomTextField(controller: _phoneController, hintText: 'Phone Number', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone),
            CustomTextField(controller: _avatarController, hintText: 'Avatar Image URL (http...)', prefixIcon: Icons.image_outlined),
            
            const SizedBox(height: 16),
            
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return CustomButton(
                  text: 'SAVE CHANGES',
                  isLoading: auth.isLoading,
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nama tidak boleh kosong!')));
                      return;
                    }

                    // Panggil fungsi PUT /auth/profile beserta avatar
                    final success = await auth.updateProfile(
                      _nameController.text.trim(),
                      _phoneController.text.trim(),
                      _avatarController.text.trim(),
                    );
                    
                    if (!mounted) return;
                    
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profil berhasil diupdate! ✨'), backgroundColor: Colors.green)
                      );
                    } else {
                      // Tampilkan pesan error dari provider
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(auth.errorMessage ?? 'Gagal mengupdate profil.'), backgroundColor: Colors.red)
                      );
                    }
                  },
                );
              }
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