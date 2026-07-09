import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../utils/constants.dart';

/// Kelas Provider untuk mengelola data ulasan (review) produk.
class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  /// Mendapatkan daftar ulasan.
  List<ReviewModel> get reviews => _reviews;
  
  /// Mengembalikan status apakah proses sedang memuat (loading).
  bool get isLoading => _isLoading;

  /// GET: Mengambil daftar ulasan untuk sebuah produk berdasarkan [productId].
  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    Future.microtask(() => notifyListeners());

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> data = [];
        if (responseData is List) {
          data = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          data = responseData['data'] is List ? responseData['data'] : [];
        }
        _reviews = data.map((json) => ReviewModel.fromJson(json)).toList();
      } else {
        _reviews = [];
      }
    } catch (e) {
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// POST: Menambahkan ulasan baru.
  /// Memerlukan [token], [productId], [rating], dan [comment].
  /// Mengembalikan nilai true jika berhasil, atau false jika gagal.
  Future<bool> addReview(String token, String productId, double rating, String comment) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId');
      final response = await http.post(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({
          'rating': rating, // API meminta rating dalam bentuk angka (int/double)
          'comment': comment,
        }),
      );

      // Sesuai screenshot Swagger, jika berhasil mengembalikan status 201 (Created)
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchReviews(productId); // Segarkan daftar ulasan agar yang baru muncul
        return true;
      }
      print("🚨 [ERROR ADD REVIEW API]: Status: ${response.statusCode}, Body: ${response.body}");
      return false;
    } catch (e) {
      print("🚨 [ERROR ADD REVIEW]: $e");
      return false;
    }
  }

  /// DELETE: Menghapus ulasan milik pengguna.
  /// Memerlukan [token], ID ulasan [reviewId], dan ID produk [productId] untuk penyegaran data.
  /// Mengembalikan nilai true jika berhasil dihapus, atau false jika gagal.
  Future<bool> deleteReview(String token, String reviewId, String productId) async {
    try {
      // Perhatikan URL-nya menggunakan ID Ulasan (reviewId), bukan Product ID
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/$reviewId');
      final response = await http.delete(
        url,
        headers: ApiConstants.getHeaders(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        await fetchReviews(productId); // Segarkan layar setelah dihapus
        return true;
      }
      return false;
    } catch (e) {
      print("🚨 [ERROR DELETE REVIEW]: $e");
      return false;
    }
  }
}