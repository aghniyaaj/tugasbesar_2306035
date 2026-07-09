import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/wishlist_provider.dart'; 
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

/// Kelas ini merupakan layar untuk menampilkan detail sebuah produk.
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  /// Konstruktor untuk membuat [ProductDetailScreen].
  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  /// Method untuk membuat state dari [ProductDetailScreen].
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

/// State untuk [ProductDetailScreen].
class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _ratingBintangInput = 5;
  final TextEditingController _commentController = TextEditingController();
  ProductModel? _localProductDetail;
  bool _isLoadingDetail = false;

  /// Method untuk inisialisasi state, mengambil ulasan dan detail produk.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReviewProvider>(context, listen: false).fetchReviews(widget.productId);
      _checkAndFetchProductDetails();
    });
  }

  /// Method untuk memeriksa ketersediaan produk lokal atau mengambil detail produk dari server.
  Future<void> _checkAndFetchProductDetails() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    try {
      _localProductDetail = productProvider.products.firstWhere((p) => p.id == widget.productId);
      if (mounted) setState(() {}); 
    } catch (e) {
      setState(() => _isLoadingDetail = true);
      try {
        final url = Uri.parse('${ApiConstants.baseUrl}/products/${widget.productId}');
        final response = await http.get(url);
        if (response.statusCode == 200) {
          final data = json.decode(response.body)['data'] ?? json.decode(response.body);
          setState(() => _localProductDetail = ProductModel.fromJson(data));
        }
      } catch (err) {
         print("🚨 [ERROR DETAIL]: $err");
      } finally {
        if (mounted) setState(() => _isLoadingDetail = false);
      }
    }
  }

  /// Method untuk membersihkan controller saat state dihapus.
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  /// Method untuk menampilkan bottom sheet form pengisian ulasan.
  void _showReviewBottomSheet(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, top: 24, left: 24, right: 24),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tulis Ulasanmu', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Serif', color: isDark ? Colors.white : AppColors.textDark)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < _ratingBintangInput ? Icons.star : Icons.star_border, color: Colors.orange, size: 36),
                        onPressed: () => setSheetState(() => _ratingBintangInput = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    style: TextStyle(color: isDark ? Colors.white : AppColors.textDark),
                    decoration: InputDecoration(
                      hintText: 'Apa pendapatmu tentang produk ini?',
                      hintStyle: const TextStyle(color: AppColors.textGrey),
                      filled: true,
                      fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade100,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      if (_commentController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar tidak boleh kosong!')));
                        return;
                      }
                      final token = Provider.of<AuthProvider>(context, listen: false).token;
                      if (token == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login terlebih dahulu untuk mengirim ulasan!')));
                        return;
                      }
                      final success = await Provider.of<ReviewProvider>(context, listen: false).addReview(token, widget.productId, _ratingBintangInput.toDouble(), _commentController.text.trim());
                      if (!mounted) return;
                      if (success) { 
                        Navigator.pop(context); 
                        _commentController.clear(); 
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ulasan berhasil dikirim!'), backgroundColor: Colors.green));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal mengirim ulasan.'), backgroundColor: Colors.red));
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                    child: const Text('KIRIM ULASAN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            );
          }
        );
      }
    );
  }

  /// Method untuk membangun UI layar detail produk.
  @override
  Widget build(BuildContext context) {
    if (_isLoadingDetail) return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, body: const Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (_localProductDetail == null) return Scaffold(backgroundColor: Theme.of(context).scaffoldBackgroundColor, appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0), body: const Center(child: Text("Produk tidak ditemukan!")));

    final product = _localProductDetail!;
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              final isFav = wishlistProvider.isWishlisted(product.id);
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? AppColors.primary : (isDark ? Colors.white : AppColors.textGrey)),
                onPressed: () => wishlistProvider.toggleWishlist(product), 
              );
            }
          )
        ],
      ),
      extendBodyBehindAppBar: true, 
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400, width: double.infinity, color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
              child: Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50))
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.category.toUpperCase(), style: const TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Serif')),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Formatters.formatRupiah(product.price), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                            Text('Stok: ${product.stock}', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Consumer<ReviewProvider>(
                        builder: (context, reviewProvider, child) {
                          double displayRating = product.rating;
                          int totalReviews = reviewProvider.reviews.length;
                          if (totalReviews > 0) {
                            double totalScore = 0;
                            for (var r in reviewProvider.reviews) totalScore += r.rating;
                            displayRating = totalScore / totalReviews;
                          }
                          return Row(
                            children: [
                              const Icon(Icons.star, color: Colors.orange, size: 18),
                              const SizedBox(width: 4),
                              Text(displayRating > 0 ? displayRating.toStringAsFixed(1) : '0', style: const TextStyle(color: AppColors.textGrey, fontSize: 14, fontWeight: FontWeight.bold)),
                              if (totalReviews > 0) Text(' ($totalReviews)', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                            ],
                          );
                        }
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('DESCRIPTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Text(product.description, style: TextStyle(color: textColor, height: 1.5)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('REVIEWS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                      GestureDetector(onTap: () => _showReviewBottomSheet(context), child: const Text('Tulis Ulasan', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)))
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<ReviewProvider>(
                    builder: (context, reviewProvider, child) {
                      if (reviewProvider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                      if (reviewProvider.reviews.isEmpty) return const Text('Belum ada ulasan.', style: TextStyle(color: AppColors.textGrey, fontStyle: FontStyle.italic));

                      final currentUserName = Provider.of<AuthProvider>(context, listen: false).user?.fullName;
                      final token = Provider.of<AuthProvider>(context, listen: false).token;

                      return ListView.builder(
                        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviewProvider.reviews.length,
                        itemBuilder: (context, index) {
                          final review = reviewProvider.reviews[index];
                          final isMyReview = review.reviewerName == currentUserName;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isMyReview ? AppColors.primary.withOpacity(0.5) : borderColor)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(review.reviewerName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                                    Row(
                                      children: [
                                        if (isMyReview && token != null)
                                          GestureDetector(onTap: () => reviewProvider.deleteReview(token, review.id, widget.productId), child: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.delete_outline, color: Colors.red, size: 18))),
                                        ...List.generate(5, (starIndex) => Icon(starIndex < review.rating ? Icons.star : Icons.star_border, size: 14, color: Colors.orange))
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review.comment, style: TextStyle(color: textColor, fontSize: 13)),
                                if (review.createdAt.isNotEmpty) ...[const SizedBox(height: 8), Text(Formatters.formatDate(review.createdAt), style: const TextStyle(color: AppColors.textGrey, fontSize: 10))]
                              ],
                            ),
                          );
                        }
                      );
                    }
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cardColor, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: product.stock == 0 ? null : () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              if (authProvider.token == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap login terlebih dahulu!')));
                return;
              }
              
              final cartProvider = Provider.of<CartProvider>(context, listen: false);
              final success = await cartProvider.addToCart(authProvider.token!, product.id, 1);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil ditambahkan ke keranjang!'), backgroundColor: Colors.green));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal menambahkan ke keranjang.'), backgroundColor: Colors.red));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, 
              disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade400,
              padding: const EdgeInsets.symmetric(vertical: 16), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
            ),
            child: Text(
              product.stock == 0 ? 'SOLD OUT' : 'ADD TO CART', 
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)
            ),
          ),
        ),
      ),
    );
  }
}