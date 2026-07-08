import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../product/product_detail_screen.dart'; 
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<CartProvider>(context, listen: false).fetchCart(token);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    
    // DETEKSI TEMA
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    
    // Sesuai Figma: Menggunakan Card Color #1E1E1E
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white; 
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Cart', style: TextStyle(color: textColor, fontFamily: 'Serif', fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          if (cartProvider.itemCount == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Keranjang belanja kosong.', style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          final cart = cartProvider.cart!;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    final item = cart.items[index];
                    final isSelected = cartProvider.selectedProductIds.contains(item.product.id);
                    final currentQty = cartProvider.getQuantity(item.product.id, item.quantity);
                    final subtotal = item.product.price * currentQty;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // KOTAK CENTANG
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0, right: 8.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Checkbox(
                                value: isSelected,
                                activeColor: AppColors.primary,
                                checkColor: Colors.white,
                                side: BorderSide(color: isDark ? Colors.grey.shade600 : Colors.grey.shade400, width: 1.5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                onChanged: (_) => cartProvider.toggleSelection(item.product.id),
                              ),
                            ),
                          ),
                          
                          // GAMBAR PRODUK
                          GestureDetector(
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: item.product.id))),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 70, height: 70, fit: BoxFit.cover,
                                errorBuilder: (ctx, err, stack) => Container(width: 70, height: 70, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200, child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          
                          // DESKRIPSI, QTY & HARGA
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.product.name, 
                                        style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14), 
                                        maxLines: 2, overflow: TextOverflow.ellipsis
                                      )
                                    ),
                                    GestureDetector(
                                      onTap: () => cartProvider.removeCartItem(token!, item.id, item.product.id),
                                      child: const Icon(Icons.delete_outline, color: AppColors.textGrey, size: 20),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // PENGATUR QTY MINIMALIS (Minus & Plus)
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => cartProvider.updateCartItemQty(token!, item.id, item.product.id, currentQty - 1),
                                          child: Icon(Icons.remove_circle_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 22),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12),
                                          child: Text('$currentQty', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 14)),
                                        ),
                                        GestureDetector(
                                          onTap: () => cartProvider.updateCartItemQty(token!, item.id, item.product.id, currentQty + 1),
                                          child: Icon(Icons.add_circle_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, size: 22),
                                        ),
                                      ],
                                    ),
                                    
                                    // HARGA SUBTOTAL
                                    Text(
                                      Formatters.formatRupiah(subtotal), 
                                      style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.accentPeach : AppColors.primary, fontSize: 14)
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // BOTTOM CHECKOUT BAR (Sesuai Figma)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor, // Menyatu dengan background aplikasi
                  border: Border(top: BorderSide(color: borderColor)),
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Grand Total', style: TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatRupiah(cartProvider.grandTotal),
                            style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 18),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: cartProvider.selectedProductIds.isEmpty 
                            ? null 
                            : () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}