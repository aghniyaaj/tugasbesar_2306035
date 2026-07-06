import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
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
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.token != null) {
        Provider.of<CartProvider>(context, listen: false).fetchCart(authProvider.token!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil auth token untuk memanggil fungsi delete/update qty API
    final String? token = Provider.of<AuthProvider>(context, listen: false).token;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('My Cart', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        centerTitle: true,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading && (cartProvider.cart == null || cartProvider.cart!.items.isEmpty)) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          if (cartProvider.cart == null || cartProvider.cart!.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text('Keranjang belanja Anda masih kosong.', style: TextStyle(color: AppColors.textGrey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cartProvider.cart!.items.length,
            itemBuilder: (context, index) {
              final item = cartProvider.cart!.items[index];
              final isSelected = cartProvider.selectedProductIds.contains(item.product.id);
              final qty = cartProvider.getQuantity(item.product.id, item.quantity);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5))],
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      activeColor: AppColors.primary,
                      onChanged: (_) => cartProvider.toggleSelection(item.product.id),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.product.imageUrl,
                        width: 70, height: 70, fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70, height: 70, color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(Formatters.formatRupiah(item.product.price * qty), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    // KONTROL QUANTITY & DELETE
                    Row(
                      children: [
                        // Ikon Hapus
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            if (token != null) cartProvider.removeCartItem(token, item.id, item.product.id);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppColors.textGrey),
                          onPressed: () {
                            if (token != null) cartProvider.updateCartItemQty(token, item.id, item.product.id, qty - 1);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppColors.textGrey),
                          onPressed: () {
                            if (token != null) cartProvider.updateCartItemQty(token, item.id, item.product.id, qty + 1);
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final total = cartProvider.grandTotal;
          final hasSelection = cartProvider.selectedProductIds.isNotEmpty;

          return Visibility(
            visible: hasSelection,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Grand Total', style: TextStyle(color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                        Text(Formatters.formatRupiah(total), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CheckoutScreen()));
                        }, 
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        child: const Text('CHECKOUT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}