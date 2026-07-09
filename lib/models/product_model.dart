/// Model yang merepresentasikan data Produk.
class ProductModel {
  /// ID unik produk.
  final String id;
  /// Nama produk.
  final String name;
  /// Deskripsi tentang produk.
  final String description;
  /// Harga produk.
  final double price;
  /// URL gambar produk.
  final String imageUrl;
  /// Kategori produk.
  final String category;
  /// Jumlah stok produk yang tersedia.
  final int stock;
  /// Rating rata-rata produk.
  final double rating;
  /// Jumlah ulasan pada produk.
  final int reviewCount;

  /// Konstruktor untuk menginisialisasi objek [ProductModel].
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.rating = 0.0,
    this.reviewCount = 0,
  });

  /// Method factory untuk membuat objek [ProductModel] dari data JSON.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // FITUR PERBAIKAN: Menangani kategori yang berbentuk objek nested (bersarang)
    String parsedCategory = 'Uncategorized';
    if (json['categories'] != null) {
      if (json['categories'] is Map) {
        parsedCategory = json['categories']['name']?.toString() ?? 'Uncategorized';
      } else {
        parsedCategory = json['categories'].toString();
      }
    } else if (json['category'] != null) {
      parsedCategory = json['category'].toString();
    }

    return ProductModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Product',
      description: json['description']?.toString() ?? 'No description available',
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      
      // FITUR PERBAIKAN: Menangani snake_case pada API Postman
      imageUrl: json['image_url']?.toString() ?? json['imageUrl']?.toString() ?? '',
      category: parsedCategory,
      stock: int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      reviewCount: int.tryParse(json['review_count']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Model yang merepresentasikan data Ulasan (Review) pada Detail Produk.
class ReviewModel {
  /// ID unik ulasan.
  final String id;
  /// Nilai rating yang diberikan.
  final double rating;
  /// Komentar atau isi ulasan.
  final String comment;
  /// Nama pengguna yang memberikan ulasan.
  final String reviewerName;
  /// Tanggal ulasan dibuat.
  final String createdAt;

  /// Konstruktor untuk menginisialisasi objek [ReviewModel].
  ReviewModel({
    required this.id,
    required this.rating,
    required this.comment,
    required this.reviewerName,
    required this.createdAt,
  });

  /// Method factory untuk membuat objek [ReviewModel] dari data JSON.
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Menangani nama reviewer yang biasanya ada di dalam objek 'reviewer'
    String parsedReviewerName = 'Anonymous';
    if (json['reviewer'] != null) {
      if (json['reviewer'] is Map) {
        parsedReviewerName = json['reviewer']['full_name']?.toString() ?? 
                             json['reviewer']['name']?.toString() ?? 
                             'Anonymous';
      } else {
        parsedReviewerName = json['reviewer'].toString();
      }
    }

    return ReviewModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
      comment: json['comment']?.toString() ?? '',
      reviewerName: parsedReviewerName,
      createdAt: json['created_at']?.toString() ?? json['createdAt']?.toString() ?? '',
    );
  }
}