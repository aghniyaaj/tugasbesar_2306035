import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../utils/constants.dart';

/// Kelas Provider untuk mengelola data produk dan kategori.
class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _currentCategory = 'All';
  String _currentSort = 'newest';
  int _currentLimit = 10; 

  /// Mendapatkan daftar produk.
  List<ProductModel> get products => _products;
  
  /// Mendapatkan daftar kategori produk.
  List<String> get categories => _categories;
  
  /// Mengembalikan status apakah proses sedang memuat (loading).
  bool get isLoading => _isLoading;
  
  /// Mendapatkan pesan error jika terjadi kesalahan.
  String? get errorMessage => _errorMessage;
  
  /// Mendapatkan kategori produk yang saat ini dipilih.
  String get currentCategory => _currentCategory;
  
  /// Mendapatkan jenis urutan (sort) yang saat ini diterapkan.
  String get currentSort => _currentSort;
  
  /// Mendapatkan batas (limit) jumlah produk yang dimuat.
  int get currentLimit => _currentLimit;

  /// Method untuk mengambil daftar produk dari server.
  /// Dapat difilter menggunakan parameter [search], [category], [sort], dan [limit].
  Future<void> fetchProducts({String? search, String? category, String? sort, int? limit}) async {
    _isLoading = true;
    _errorMessage = null;

    if (category != null) _currentCategory = category;
    if (sort != null) _currentSort = sort;
    if (limit != null) _currentLimit = limit;

    Future.microtask(() => notifyListeners());

    try {
      Map<String, String> queryParams = {};
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      
      // Tetap kirim kategori ke API
      if (_currentCategory != 'All') {
        queryParams['category'] = _currentCategory; 
      }
      
      queryParams['sort'] = _currentSort;
      queryParams['limit'] = _currentLimit.toString(); 

      final uri = Uri.parse('${ApiConstants.baseUrl}/products').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        List<dynamic> productsJson = [];
        if (responseData['data'] != null && responseData['data'] is List) {
          productsJson = responseData['data'];
        } else if (responseData is List) {
          productsJson = responseData;
        }

        List<ProductModel> fetchedProducts = productsJson.map((json) => ProductModel.fromJson(json)).toList();

        // 🔥 FILTER LOKAL MUTLAK (MENGATASI API BOCOR) 🔥
        // Jika pilih Baju Tidur, maka barang Elektronik akan DIBUANG dari layar!
        if (_currentCategory != 'All') {
          _products = fetchedProducts.where((p) {
            return p.category.trim().toLowerCase() == _currentCategory.trim().toLowerCase();
          }).toList();
        } else {
          _products = fetchedProducts;
        }
      } else {
        _errorMessage = 'Gagal memuat produk.';
      }
    } catch (error) {
      _errorMessage = 'Terjadi kesalahan koneksi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Method untuk mengambil daftar kategori produk dari server.
  Future<void> fetchCategories() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/categories');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null && responseData['data'] is List) {
          final List<dynamic> categoriesJson = responseData['data'];
          
          // 🔥 FILTER KATEGORI (HAPUS UNCATEGORIZED) 🔥
          List<String> fetchedCategories = categoriesJson
              .map((c) => c['name']?.toString().trim() ?? '')
              .where((name) => name.isNotEmpty && name.toLowerCase() != 'uncategorized' && name.toLowerCase() != 'unnamed category')
              .toSet() // Pakai toSet() agar tidak ada kategori ganda
              .toList();
              
          _categories = ['All', ...fetchedCategories];
          notifyListeners();
          return;
        }
      }
      
      // Fallback
      _categories = ['All', 'Beauty', 'Fashion', 'Electronics'];
      notifyListeners();
      
    } catch (error) {
      // Fallback
      _categories = ['All', 'Beauty', 'Fashion', 'Electronics'];
      notifyListeners();
    }
  }
}