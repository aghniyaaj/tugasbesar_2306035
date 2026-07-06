import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ReviewProvider with ChangeNotifier {
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;

  Future<void> fetchReviews(String productId) async {
    _isLoading = true;
    // Menggunakan Future.microtask untuk menghindari error pembaruan state saat build
    Future.microtask(() => notifyListeners());

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Menyesuaikan dengan format API (biasanya dibungkus dalam 'data')
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
      print("🚨 [ERROR FETCH REVIEWS]: $e");
      _reviews = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addReview(String token, String productId, double rating, String comment) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/reviews/product/$productId');
      final response = await http.post(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({
          'rating': rating,
          'comment': comment,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Tarik ulang daftar ulasan agar ulasan baru langsung muncul
        await fetchReviews(productId);
        return true;
      }
      return false;
    } catch (e) {
      print("🚨 [ERROR ADD REVIEW]: $e");
      return false;
    }
  }
}