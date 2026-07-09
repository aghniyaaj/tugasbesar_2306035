import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';
import '../utils/constants.dart';

/// Kelas Provider untuk mengelola data pesanan (order).
class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  /// Mendapatkan daftar riwayat pesanan.
  List<OrderModel> get orders => _orders;
  
  /// Mengembalikan status apakah proses sedang memuat (loading).
  bool get isLoading => _isLoading;
  
  /// Mendapatkan pesan error jika terjadi kesalahan.
  String? get errorMessage => _errorMessage;

  /// Method untuk mengambil daftar riwayat pesanan dari server berdasarkan [token].
  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        print("📦 [DEBUG ORDER] Response: ${response.body}");
        final responseData = json.decode(response.body);
        List<dynamic> ordersJson = [];
        if (responseData is List) {
          ordersJson = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          ordersJson = responseData['data'] is List ? responseData['data'] : [];
        }
        try {
          _orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
        } catch (parseError) {
          print("🚨 [ERROR PARSING ORDER]: $parseError");
          _errorMessage = 'Kesalahan format data pesanan.';
        }
      } else {
        print("🚨 [ERROR ORDER API]: Status ${response.statusCode}, Body: ${response.body}");
        _errorMessage = 'Gagal memuat riwayat pesanan.';
      }
    } catch (e) {
      print("🚨 [ERROR FETCH ORDER]: $e");
      _errorMessage = 'Terjadi kesalahan koneksi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Method untuk mengambil detail dari sebuah pesanan tertentu berdasarkan [orderId].
  Future<OrderModel?> getOrderDetailsById(String token, String orderId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders/$orderId');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        return OrderModel.fromJson(data);
      }
      return null;
    } catch (e) {
      print("🚨 [ERROR FETCH DETAIL]: $e");
      return null;
    }
  }

  /// Method untuk membuat (place) pesanan baru dengan menyertakan [address] dan [notes].
  /// Mengembalikan nilai true jika pesanan berhasil dibuat, atau false jika gagal.
  Future<bool> placeOrder(String token, String address, String? notes) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders');
      final response = await http.post(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({
          'shipping_address': address,
          'notes': notes ?? '',
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchOrders(token);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}