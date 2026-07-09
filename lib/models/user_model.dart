/// Model yang merepresentasikan data pengguna (User).
class UserModel {
  /// ID unik dari pengguna.
  final String id;
  /// Nama lengkap dari pengguna.
  final String fullName;
  /// Alamat email dari pengguna.
  final String email;
  /// Nomor telepon dari pengguna (opsional).
  final String? phoneNumber;
  /// Peran (role) dari pengguna, misalnya 'customer'.
  final String role;
  /// URL gambar profil pengguna (opsional).
  final String? avatarUrl; // TAMBAHAN: Menyimpan URL foto profil

  /// Konstruktor untuk menginisialisasi objek [UserModel].
  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
  });

  /// Method factory untuk membuat objek [UserModel] dari data JSON.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      String parsedRole = 'customer';
      if (json['role'] != null) {
        if (json['role'] is Map) {
          parsedRole = json['role']['name']?.toString() ?? 'customer';
        } else {
          parsedRole = json['role'].toString();
        }
      }

      return UserModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
        fullName: json['full_name']?.toString() ?? 
                  json['fullName']?.toString() ?? 
                  json['name']?.toString() ?? 'User',
        email: json['email']?.toString() ?? '',
        phoneNumber: json['phone']?.toString() ?? 
                     json['phoneNumber']?.toString() ?? 
                     json['phone_number']?.toString(),
        role: parsedRole,
        // MENANGKAP AVATAR DARI API
        avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      );
    } catch (e) {
      print("🚨 [ERROR PARSING USER]: $e");
      rethrow;
    }
  }

  /// Method untuk mengubah objek [UserModel] menjadi bentuk JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
}