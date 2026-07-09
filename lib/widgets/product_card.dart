import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/constants.dart';
import '../utils/formatters.dart';

/// Kelas ini merupakan widget kartu untuk menampilkan ringkasan produk.
class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  /// Konstruktor untuk membuat [ProductCard].
  const ProductCard({
    Key? key,
    required this.product,
    required this.onTap,
  }) : super(key: key);

  /// Method untuk membangun UI kartu produk.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  product.imageUrl.isNotEmpty 
                      ? product.imageUrl 
                      : 'https://via.placeholder.com/150',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => 
                      Container(color: Colors.grey.shade100, child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category.toUpperCase(), 
                    style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold)
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatRupiah(product.price),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}