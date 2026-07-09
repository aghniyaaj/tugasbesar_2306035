import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_model.dart';
import '../utils/constants.dart';

/// Kelas Provider untuk mengelola status dan data keranjang belanja (cart).
class CartProvider with ChangeNotifier {
  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  /// Mendapatkan model keranjang belanja saat ini.
  CartModel? get cart => _cart;
  
  /// Mengembalikan status apakah proses sedang memuat (loading).
  bool get isLoading => _isLoading;
  
  /// Mendapatkan pesan error jika terjadi kesalahan.
  String? get errorMessage => _errorMessage;
  
  /// Mendapatkan jumlah total item (jenis produk) di dalam keranjang.
  int get itemCount => _cart?.items.length ?? 0;

  /// Method untuk menghitung total keseluruhan (grand total) dari semua item di keranjang.
  double get grandTotal {
    if (_cart == null) return 0.0;
    double total = 0.0;
    for (var item in _cart!.items) {
      total += (item.product.price * item.quantity);
    }
    return total;
  }

  /// Method untuk mengambil data keranjang dari server berdasarkan [token].
  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        print("🛒 [DEBUG CART] Response: ${response.body}");
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        try {
          // Handle jika API mengembalikan List (array kosong) langsung
          if (data is List) {
             _cart = CartModel(
               items: data.map((i) => CartItemModel.fromJson(i as Map<String, dynamic>)).toList(),
               grandTotal: 0.0
             );
          } else {
             _cart = CartModel.fromJson(data);
          }
        } catch (parseError) {
          print("🚨 [ERROR PARSING CART]: $parseError");
          _errorMessage = 'Kesalahan format data: $parseError';
        }
      } else {
        print("🚨 [ERROR CART API]: Status ${response.statusCode}, Body: ${response.body}");
        _errorMessage = 'Gagal memuat keranjang.';
      }
    } catch (e) {
      print("🚨 [ERROR FETCH CART]: $e");
      _errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Method untuk menambahkan produk ke dalam keranjang.
  /// Memerlukan [token], [productId], dan jumlah [quantity].
  /// Mengembalikan nilai true jika berhasil, atau false jika gagal.
  Future<bool> addToCart(String token, String productId, int quantity) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.post(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({'product_id': productId, 'quantity': quantity}),
      );

      // Jika berhasil (200 atau 201 Created), panggil ulang fetchCart agar datanya sinkron
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCart(token);
        return true;
      } else {
        print("🚨 [ERROR ADD TO CART API]: Status ${response.statusCode}, Body: ${response.body}");
        // Jika API error (misal 429), kita tetep coba fetchCart buat jaga-jaga
        await fetchCart(token);
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Method untuk memperbarui jumlah item (quantity) dalam keranjang.
  /// Jika [newQty] kurang dari 1, item akan dihapus dari keranjang.
  Future<void> updateCartItemQty(String token, String cartItemId, String productId, int newQty) async {
    if (newQty < 1) {
      // Jika qty dikurangi sampai 0, panggil fungsi hapus
      await removeCartItem(token, cartItemId, productId);
      return;
    }

    try {
      // Optimistic Update: Ubah di layar dulu agar responsif
      if (_cart != null) {
        final index = _cart!.items.indexWhere((item) => item.product.id == productId);
        if (index != -1) {
          final oldItem = _cart!.items[index];
          _cart!.items[index] = CartItemModel(
            id: oldItem.id,
            product: oldItem.product,
            quantity: newQty,
            subtotal: oldItem.product.price * newQty,
          );
          notifyListeners();
        }
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId');
      await http.put(
        url,
        headers: ApiConstants.getHeaders(token),
        body: json.encode({'quantity': newQty}),
      );
      
      // Sinkronkan kembali dengan server
      await fetchCart(token);
    } catch (e) {
      print("🚨 [ERROR UPDATE QTY]: $e");
    }
  }

  /// Method untuk menghapus sebuah item dari dalam keranjang berdasarkan ID-nya.
  Future<void> removeCartItem(String token, String cartItemId, String productId) async {
    try {
      
      // Optimistic Update: Hapus dari UI sementara
      if (_cart != null) {
        _cart!.items.removeWhere((item) => item.product.id == productId);
        notifyListeners();
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/cart/$cartItemId');
      await http.delete(url, headers: ApiConstants.getHeaders(token));
      
      // Sinkronisasi ulang dengan API
      await fetchCart(token);
    } catch (e) {
      print("🚨 [ERROR DELETE ITEM]: $e");
    }
  }



  /// Method untuk mendapatkan kuantitas (quantity) barang tertentu di keranjang.
  /// Akan mengembalikan [fallbackQty] jika barang tidak ditemukan.
  int getQuantity(String productId, int fallbackQty) {
    if (_cart == null) return fallbackQty;
    try {
      final item = _cart!.items.firstWhere((element) => element.product.id == productId);
      return item.quantity;
    } catch (e) {
      return fallbackQty;
    }
  }
}