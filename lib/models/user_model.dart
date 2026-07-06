class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;
  final String? avatarUrl; // TAMBAHAN: Menyimpan URL foto profil

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
  });

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