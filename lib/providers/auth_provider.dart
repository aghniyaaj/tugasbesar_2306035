import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

/// Kelas Provider untuk mengelola status dan logika autentikasi pengguna.
/// Memanfaatkan [ChangeNotifier] untuk memperbarui UI saat status berubah.
class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isLoading = false;
  String? _errorMessage; 
  UserModel? _user;      

  /// Mengembalikan true jika pengguna sudah terautentikasi (memiliki token).
  bool get isAuth => _token != null;
  
  /// Mendapatkan token autentikasi pengguna.
  String? get token => _token;
  
  /// Mengembalikan status apakah proses sedang memuat (loading).
  bool get isLoading => _isLoading;
  
  /// Mendapatkan pesan error jika terjadi kesalahan.
  String? get errorMessage => _errorMessage;
  
  /// Mendapatkan model pengguna saat ini.
  UserModel? get user => _user;

  /// Method untuk melakukan login dengan [email] dan [password].
  /// Mengembalikan nilai true jika login berhasil, atau false jika gagal.
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

  /// Method untuk mendaftarkan akun baru dengan [name], [email], dan [password].
  /// Mengembalikan nilai true jika pendaftaran berhasil, atau false jika gagal.
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

  /// Method untuk melakukan proses keluar (logout) pengguna.
  /// Menghapus token dari [SharedPreferences] dan me-reset status.
  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  /// Method untuk mencoba melakukan login otomatis jika token masih tersimpan.
  /// Mengembalikan nilai true jika berhasil login otomatis, false jika gagal.
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

  /// Method untuk mengambil data profil pengguna dari server.
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

  /// Method untuk memperbarui data profil pengguna seperti [newName], [newPhone], dan [newAvatar].
  /// Mengembalikan nilai true jika update berhasil, atau false jika gagal.
  Future<bool> updateProfile(String newName, String newPhone, String newAvatar) async {
    if (_token == null) return false;
    
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiConstants.baseUrl}/auth/profile');
      
      Map<String, dynamic> requestBody = {
        'full_name': newName,
      };

      if (newPhone.isNotEmpty) {
        requestBody['phone'] = newPhone;
      }
      
      if (newAvatar.isNotEmpty) {
        requestBody['avatar_url'] = newAvatar;
      }

      final response = await http.put(
        url,
        headers: ApiConstants.getHeaders(_token),
        body: jsonEncode(requestBody),
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