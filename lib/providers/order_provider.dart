import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchOrders(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/orders');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        List<dynamic> ordersJson = [];
        if (responseData is List) {
          ordersJson = responseData;
        } else if (responseData is Map && responseData.containsKey('data')) {
          ordersJson = responseData['data'] is List ? responseData['data'] : [];
        }
        _orders = ordersJson.map((json) => OrderModel.fromJson(json)).toList();
      } else {
        _errorMessage = 'Gagal memuat riwayat pesanan.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan koneksi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FITUR BARU: MENGAMBIL DETAIL PESANAN ---
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