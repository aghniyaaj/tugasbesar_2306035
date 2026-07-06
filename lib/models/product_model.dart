import 'dart:convert';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String category;
  final String imageUrl;
  final double averageRating;
  final int reviewCount;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.category,
    required this.imageUrl,
    required this.averageRating,
    required this.reviewCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      String parsedCategory = 'Uncategorized';
      var catData = json['category'];
      
      if (catData != null) {
        if (catData is Map) {
          parsedCategory = catData['name']?.toString() ?? 'Uncategorized';
        } else if (catData is String) {
          // Jika API mengirim string yang menyerupai JSON (contoh: "{id: 123, name: botol}")
          if (catData.startsWith('{')) {
            try {
              // Bersihkan sedikit jika format API-nya kacau, lalu decode
              var cleanedString = catData.replaceAll(RegExp(r'(\w+):'), r'"$1":');
              var decoded = jsonDecode(cleanedString);
              parsedCategory = decoded['name']?.toString() ?? 'Uncategorized';
            } catch (e) {
              parsedCategory = 'Uncategorized';
            }
          } else {
            parsedCategory = catData;
          }
        }
      } else if (json['category_name'] != null) {
        parsedCategory = json['category_name'].toString();
      }

      return ProductModel(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? 'Unknown Product',
        description: json['description']?.toString() ?? '',
        price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
        stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
        category: parsedCategory, 
        
        // PERBAIKAN: Menambahkan pendeteksi kunci "image_url" sesuai data Postman
        imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? json['image']?.toString() ?? '', 
        
        averageRating: double.tryParse(json['averageRating']?.toString() ?? json['rating']?.toString() ?? '0') ?? 0.0,
        reviewCount: int.tryParse(json['reviewCount']?.toString() ?? '0') ?? 0,
      );
    } catch (e) {
      print("🚨 [ERROR PARSING PRODUCT]: $e");
      rethrow;
    }
  }
}

/// Model untuk Ulasan (Review) Produk
class ReviewModel {
  final String id;
  final String userName;
  final double rating;
  final String comment;
  final String date;

  ReviewModel({
    required this.id,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Mengekstrak nama dari objek "reviewer" jika ada
    String parsedUserName = 'Anonymous';
    if (json['reviewer'] != null && json['reviewer'] is Map) {
      parsedUserName = json['reviewer']['full_name']?.toString() ?? 
                       json['reviewer']['name']?.toString() ?? 
                       'Anonymous';
    } else if (json['user'] != null && json['user'] is Map) {
      parsedUserName = json['user']['full_name']?.toString() ?? 'Anonymous';
    }

    return ReviewModel(
      id: json['id']?.toString() ?? '',
      userName: parsedUserName,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      // Mencoba mencari tanggal dari created_at
      date: json['created_at']?.toString() ?? json['date']?.toString() ?? '',
    );
  }
}