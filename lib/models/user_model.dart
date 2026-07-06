class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      // PERBAIKAN 1: Ekstrak role jika bentuknya objek Map (seperti di Postman)
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
        
        // PERBAIKAN 2: Menambahkan deteksi kunci "full_name" (Sesuai Postman)
        fullName: json['full_name']?.toString() ?? 
                  json['fullName']?.toString() ?? 
                  json['name']?.toString() ?? 
                  'User',
                  
        email: json['email']?.toString() ?? '',
        
        // PERBAIKAN 3: Menambahkan deteksi kunci "phone" (Sesuai Postman)
        phoneNumber: json['phone']?.toString() ?? 
                     json['phoneNumber']?.toString() ?? 
                     json['phone_number']?.toString(),
                     
        role: parsedRole,
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
    };
  }
}