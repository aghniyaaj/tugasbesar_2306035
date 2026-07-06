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
  int _currentLimit = 10; // Parameter limit

  List<ProductModel> get products => _products;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  String get currentCategory => _currentCategory;
  String get currentSort => _currentSort;
  int get currentLimit => _currentLimit;

  // Modifikasi untuk menerima dan mengirimkan Limit ke API
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
      if (_currentCategory != 'All') {
        queryParams['category'] = _currentCategory;
      }
      
      queryParams['sort'] = _currentSort;
      queryParams['limit'] = _currentLimit.toString(); // Kirim ke server

      final uri = Uri.parse('${ApiConstants.baseUrl}/products').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> productsJson = responseData['data'] ?? responseData;
        _products = productsJson.map((json) => ProductModel.fromJson(json)).toList();
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

  Future<void> fetchCategories() async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/categories');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> categoriesJson = responseData['data'] ?? responseData;
        
        _categories = ['All', ...categoriesJson.map((c) => c['name'].toString()).toList()];
        notifyListeners();
      }
    } catch (error) {
      _categories = ['All', 'Beauty', 'Fashion', 'Electronics'];
      notifyListeners();
    }
  }
}