import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/cart_model.dart';
import '../utils/constants.dart';

class CartProvider with ChangeNotifier {
  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  // Set untuk menyimpan ID produk yang dicentang user
  final Set<String> _selectedProductIds = {};

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Set<String> get selectedProductIds => _selectedProductIds;
  
  int get itemCount => _cart?.items.length ?? 0;

  // FITUR: Hitung Grand Total BERDASARKAN item yang dicentang saja
  double get grandTotal {
    if (_cart == null) return 0.0;
    double total = 0.0;
    for (var item in _cart!.items) {
      if (_selectedProductIds.contains(item.product.id)) {
        total += (item.product.price * item.quantity);
      }
    }
    return total;
  }

  // --- MENGAMBIL DATA KERANJANG ---
  Future<void> fetchCart(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/cart');
      final response = await http.get(url, headers: ApiConstants.getHeaders(token));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final data = responseData['data'] ?? responseData;
        _cart = CartModel.fromJson(data);
        
        // Opsional: Otomatis centang semua barang saat keranjang di-load
        if (_cart != null && _selectedProductIds.isEmpty) {
          _selectedProductIds.addAll(_cart!.items.map((e) => e.product.id));
        }
      } else {
        _errorMessage = 'Gagal memuat keranjang.';
      }
    } catch (e) {
      _errorMessage = 'Kesalahan jaringan: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FITUR BARU: ADD TO CART ---
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

  // --- UPDATE QTY ---
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

  // --- REMOVE ITEM DARI CART ---
  Future<void> removeCartItem(String token, String cartItemId, String productId) async {
    try {
      // Hapus centang dari daftar selection
      _selectedProductIds.remove(productId);
      
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

  // Fungsi utilitas untuk Centang/Hapus Centang
  void toggleSelection(String productId) {
    if (_selectedProductIds.contains(productId)) {
      _selectedProductIds.remove(productId);
    } else {
      _selectedProductIds.add(productId);
    }
    notifyListeners();
  }

  // Mendapatkan quantity barang tertentu
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