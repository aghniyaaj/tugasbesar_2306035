import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  String? _errorMessage; 
  UserModel? _user;      

  bool get isAuth => _token != null;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get user => _user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/login');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        _token = responseData['data']?['access_token'] ?? responseData['access_token']; 
        
        if (_token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', _token!);
          // Ambil profil API agar nama muncul di Home Screen
          await fetchProfile(); 
        }
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        _errorMessage = responseData['message'] ?? 'Email atau password salah.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan jaringan atau koneksi terputus.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/register');
      
      print("🔍 [DEBUG REGISTER] Mencoba mendaftar...");
      print("🔍 [DEBUG REGISTER] Data: Name=$name, Email=$email, Pass=$password");
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        // Mengirim 'name' dan 'full_name' sekaligus agar
        // dijamin tembus meskipun API memakai format snake_case!
        body: jsonEncode({
          'name': name,
          'full_name': name, 
          'email': email, 
          'password': password
        }),
      );

      print("🔍 [DEBUG REGISTER] Status Code: ${response.statusCode}");
      print("🔍 [DEBUG REGISTER] Response: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final responseData = jsonDecode(response.body);
        
        // Tangkap error spesifik dari array "errors" API 
        String extraError = '';
        if (responseData['errors'] != null) {
          extraError = '\nDetail: ${responseData['errors']}';
        }
        
        _errorMessage = (responseData['message'] ?? 'Gagal mendaftar.') + extraError;
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = "Terjadi kesalahan jaringan atau koneksi terputus.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return false;
    }
    _token = prefs.getString('token');
    // Ambil profil saat user kembali membuka aplikasi
    await fetchProfile(); 
    notifyListeners();
    return true;
  }

  // --- MENGAMBIL DATA PROFIL USER ---
  Future<void> fetchProfile() async {
    if (_token == null) return;
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/profile');
      final response = await http.get(url, headers: ApiConstants.getHeaders(_token));
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = responseData['data'] ?? responseData;
        _user = UserModel.fromJson(data);
        notifyListeners(); // Memicu Home Screen memperbarui nama
      }
    } catch (e) {
      print("🚨 [ERROR FETCH PROFILE]: $e");
    }
  }

  // --- FITUR BARU: UPDATE PROFIL (PUT) ---
  Future<bool> updateProfile(String newName, String newPhone, String newAvatar) async {
    if (_token == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/profile');
      
      // Kirim data sesuai format yang diminta API
      final response = await http.put(
        url,
        headers: ApiConstants.getHeaders(_token),
        body: jsonEncode({
          'full_name': newName,
          // Jika HP kosong, kirim null agar tidak error format validasi
          'phone': newPhone.isEmpty ? null : newPhone,
          // Jika avatar kosong, kirim null
          'avatar_url': newAvatar.isEmpty ? null : newAvatar, 
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Jika sukses, tarik ulang data profil terbaru dari server
        await fetchProfile();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        print("🚨 [ERROR UPDATE PROFILE API]: ${response.body}");
        _errorMessage = 'Gagal menyimpan. Periksa format nomor telepon.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      print("🚨 [ERROR JARINGAN UPDATE PROFILE]: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}