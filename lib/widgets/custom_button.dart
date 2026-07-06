import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// [CustomButton] adalah widget tombol kustom yang desainnya disesuaikan 
/// dengan palet warna "Bloom" (Orchid Pink).
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isOutlined;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Jika tombol berjenis outline (hanya garis pinggir)
    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          minimumSize: const Size(double.infinity, 50), // Lebar full
        ),
        child: isLoading 
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    // Jika tombol berjenis filled (warna solid dominan)
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded ala desain girly
        ),
        elevation: 0,
        minimumSize: const Size(double.infinity, 50),
      ),
      child: isLoading 
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : Text(
              text, 
              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
            ),
    );
  }
}