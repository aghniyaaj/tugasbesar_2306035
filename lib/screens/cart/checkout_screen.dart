import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../../widgets/custom_button.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({Key? key}) : super(key: key);

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitOrder() async {
    if (_addressController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alamat pengiriman minimal 10 karakter!')));
      return;
    }

    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    
    final success = await orderProvider.placeOrder(token!, _addressController.text, _notesController.text);
    if (!mounted) return;

    if (success) {
      Provider.of<CartProvider>(context, listen: false).fetchCart(token);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
          return AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
            content: Text('Pesanan berhasil dibuat!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppColors.textDark)),
            actions: [
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                  onPressed: () {
                    Navigator.pop(context); 
                    Navigator.pop(context); 
                  },
                  child: const Text('Ke Riwayat Pesanan', style: TextStyle(color: Colors.white)),
                ),
              )
            ],
          );
        }
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pesanan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;
    final selectedItems = cart?.items.where((item) => cartProvider.selectedProductIds.contains(item.product.id)).toList() ?? [];
    
    // DETEKSI TEMA
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Checkout', style: TextStyle(fontFamily: 'Serif', color: textColor)), 
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SHIPPING ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            TextField(
              controller: _addressController,
              maxLines: 3,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Enter your full shipping address...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                filled: true, fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('ORDER SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
              child: Column(
                children: [
                  ...selectedItems.map((item) {
                    final qty = cartProvider.getQuantity(item.product.id, item.quantity);
                    final subtotal = item.product.price * qty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.product.name} (x$qty)', style: TextStyle(color: textColor))),
                          Text(Formatters.formatRupiah(subtotal), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(color: borderColor),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                      Text(Formatters.formatRupiah(cartProvider.grandTotal), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.accentPeach : AppColors.primary, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('ORDER NOTES (OPTIONAL)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: 'Any special requests...',
                hintStyle: const TextStyle(color: AppColors.textGrey),
                filled: true, fillColor: cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: borderColor)),
              ),
            ),
            const SizedBox(height: 40),
            
            Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                return CustomButton(
                  text: 'PLACE ORDER',
                  isLoading: orderProvider.isLoading,
                  onPressed: _submitOrder,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}