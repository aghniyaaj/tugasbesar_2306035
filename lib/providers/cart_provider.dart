import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_model.dart';
import '../utils/constants.dart';

class CartProvider with ChangeNotifier {
  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;
  
  final Set<String> _selectedProductIds = {}; 
  final Map<String, int> _itemQuantities = {}; 

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedProductIds => _selectedProductIds;

  int get itemCount {
    if (_cart == null || _cart!.items.isEmpty) return 0;
    return _cart!.items.length;
  }

  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        _cart = CartModel.fromJson(responseData['data'] ?? responseData);
      } else {
        _errorMessage = 'Gagal memuat keranjang.';
      }
    } catch (e) {
      _errorMessage = 'Terjadi kesalahan jaringan.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addToCart(String token, String productId, int quantity) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.post(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- FITUR BARU: HAPUS DARI KERANJANG API ---
  Future<bool> removeCartItem(String token, String cartItemId, String productId) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId');
      final response = await http.delete(url, headers: ApiConstants.getHeaders(token));
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Hapus juga dari pilihan lokal agar rapi
        _selectedProductIds.remove(productId);
        _itemQuantities.remove(productId);
        await fetchCart(token); // Refresh keranjang dari server
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // --- FITUR BARU: UPDATE QTY KE API ---
  Future<void> updateCartItemQty(String token, String cartItemId, String productId, int newQty) async {
    // Jika qty kurang dari 1, otomatis panggil fungsi hapus
    if (newQty < 1) {
      await removeCartItem(token, cartItemId, productId);
      return;
    }
    
    // Update lokal dulu agar UI terasa cepat (Optimistic UI)
    _itemQuantities[productId] = newQty;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId');
      await http.put(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({'quantity': newQty}),
      );
      // Panggil fetchCart lagi jika butuh refresh grand total dari server
      // await fetchCart(token); 
    } catch (e) {
      print("🚨 [ERROR UPDATE QTY]: $e");
    }
  }

  void toggleSelection(String productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
    notifyListeners();
  }

  int getQuantity(String productId, int defaultQty) {
    return _itemQuantities[productId] ?? defaultQty;
  }

  double get grandTotal {
    double total = 0;
    if (_cart == null) return 0;
    for (var item in _cart!.items) {
      if (_selectedProductIds.contains(item.product.id)) {
        int qty = getQuantity(item.product.id, item.quantity);
        total += (item.product.price * qty);
      }
    }
    return total;
  }
}