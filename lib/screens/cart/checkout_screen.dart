import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
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
      // Hapus isi keranjang di lokal setelah sukses
      Provider.of<CartProvider>(context, listen: false).fetchCart(token);
      
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Icon(Icons.check_circle, color: Colors.green, size: 60),
          content: const Text('Pesanan berhasil dibuat!', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke cart (nanti kamu bisa arahkan lagi ke tab history)
                },
                child: const Text('Ke Riwayat Pesanan', style: TextStyle(color: Colors.white)),
              ),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Gagal membuat pesanan.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Mengambil cartProvider keseluruhan agar kita bisa memfilter
    final cartProvider = Provider.of<CartProvider>(context);
    final cart = cartProvider.cart;
    
    // HANYA AMBIL BARANG YANG DICENTANG (SELECTED) DARI KERANJANG
    final selectedItems = cart?.items.where(
      (item) => cartProvider.selectedProductIds.contains(item.product.id)
    ).toList() ?? [];
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Checkout', style: TextStyle(fontFamily: 'Serif')), centerTitle: true),
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
              decoration: InputDecoration(
                hintText: 'Enter your full shipping address...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
              ),
            ),
            const SizedBox(height: 24),
            
            const Text('ORDER SUMMARY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  // Menampilkan rincian barang hanya yang tadi kamu pilih
                  ...selectedItems.map((item) {
                    final qty = cartProvider.getQuantity(item.product.id, item.quantity);
                    final subtotal = item.product.price * qty;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text('${item.product.name} (x$qty)', style: const TextStyle(color: AppColors.textDark))),
                          Text(Formatters.formatRupiah(subtotal), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      // Total menggunakan hasil perhitungan dari item yang dicentang saja
                      Text(Formatters.formatRupiah(cartProvider.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16)),
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
              decoration: InputDecoration(
                hintText: 'Any special requests...',
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade200)),
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