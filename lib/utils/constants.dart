import 'package:flutter/material.dart';

/// Kelas ini menyimpan konstanta warna yang digunakan di seluruh aplikasi (Berdasarkan desain Figma).
class AppColors {
  /// Warna utama aplikasi (Orchid Pink) digunakan untuk tombol dan elemen aktif.
  static const Color primary = Color(0xFFE6A8D7);
  
  /// Warna latar belakang aplikasi (Warm Ivory) agar tidak menyilaukan.
  static const Color background = Color(0xFFFDFBF7);
  
  /// Warna teks utama (Dark Grey) untuk judul dan harga.
  static const Color textDark = Color(0xFF333333);
  
  /// Warna teks sekunder (Abu-abu) untuk deskripsi atau teks kecil.
  static const Color textGrey = Color(0xFF9E9E9E);
  
  /// Warna aksen lembut untuk kategori atau elemen sekunder (Peach Puff).
  static const Color accentPeach = Color(0xFFFFDAB9);
}

/// Kelas ini menyimpan konstanta untuk URL API dari tugas dosen.
class ApiConstants {
  /// Base URL endpoint untuk memanggil API.
  static const String baseUrl = "https://api-tb-f2wk.onrender.com/api";
  
  /// Method bantuan untuk mendapatkan headers HTTP beserta authorization token (jika ada).
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}