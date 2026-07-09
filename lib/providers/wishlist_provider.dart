import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

/// Kelas Provider untuk mengelola daftar produk favorit (wishlist).
class WishlistProvider with ChangeNotifier {
  List<ProductModel> _wishlistedItems = [];
  String? _currentUserId; // Menyimpan ID user yang sedang login
  
  /// Mendapatkan daftar produk yang dimasukkan ke dalam wishlist.
  List<ProductModel> get wishlistedItems => _wishlistedItems;

  /// Method untuk memeriksa apakah sebuah produk dengan [productId] ada di wishlist.
  /// Mengembalikan true jika ada, atau false jika tidak.
  bool isWishlisted(String productId) {
    return _wishlistedItems.any((item) => item.id == productId);
  }

  /// Method untuk menambah atau menghapus [product] dari wishlist.
  /// Akan otomatis menyimpan perubahan ke penyimpanan lokal.
  Future<void> toggleWishlist(ProductModel product) async {
    if (isWishlisted(product.id)) {
      _wishlistedItems.removeWhere((item) => item.id == product.id);
    } else {
      _wishlistedItems.add(product);
    }
    notifyListeners();
    await _saveWishlist();
  }

  /// Method privat untuk menyimpan ke "Laci Khusus" (wishlist) akun ini saja.
  Future<void> _saveWishlist() async {
    if (_currentUserId == null) return; // Cegah simpan jika belum login
    
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = _wishlistedItems.map((item) {
      return json.encode({
        'id': item.id,
        'name': item.name,
        'description': item.description,
        'price': item.price,
        'stock': item.stock,
        'category': item.category,
        'imageUrl': item.imageUrl,
        'rating': item.rating,
        'reviewCount': item.reviewCount,
      });
    }).toList();
    
    // Nama kunci unik per user! (Contoh: wishlist_12345)
    await prefs.setStringList('wishlist_$_currentUserId', jsonList);
  }

  /// Method untuk membuka "Laci Khusus" (memuat wishlist) milik akun [userId] yang baru login.
  Future<void> loadWishlist(String userId) async {
    _currentUserId = userId; // Ingat siapa yang sedang buka aplikasi
    final prefs = await SharedPreferences.getInstance();
    final List<String>? jsonList = prefs.getStringList('wishlist_$_currentUserId');
    
    if (jsonList != null) {
      _wishlistedItems = jsonList.map((jsonStr) {
        return ProductModel.fromJson(json.decode(jsonStr));
      }).toList();
    } else {
      _wishlistedItems = []; // Kosong jika user baru pertama kali login
    }
    notifyListeners();
  }

  /// Method yang dipanggil saat Logout: Hanya hilangkan dari layar, tapi JANGAN hapus dari HP!
  Future<void> clearMemoryOnLogout() async {
    _currentUserId = null;
    _wishlistedItems.clear(); // Hanya mengosongkan memori sementara
    notifyListeners();
  }
}