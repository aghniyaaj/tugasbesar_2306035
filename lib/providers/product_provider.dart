import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/product_model.dart';
import '../utils/constants.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<String> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  String _currentCategory = 'All';
  String _currentSort = 'newest';
  int _currentLimit = 10; 

  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String get currentCategory => _currentCategory;
  String get currentSort => _currentSort;
  int get currentLimit => _currentLimit;

  // --- MENGAMBIL DAFTAR PRODUK ---
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

  // --- MENGAMBIL DAFTAR KATEGORI ---
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