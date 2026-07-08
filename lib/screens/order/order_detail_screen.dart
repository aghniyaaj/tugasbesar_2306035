import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Future<OrderModel?>? _orderDetailsFuture;

  @override
  void initState() {
    super.initState();
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token != null) {
      _orderDetailsFuture = Provider.of<OrderProvider>(context, listen: false)
          .getOrderDetailsById(token, widget.orderId);
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.amber;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // DETEKSI TEMA
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final dividerColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Order Detail', style: TextStyle(color: textColor, fontFamily: 'Serif')),
        centerTitle: true,
      ),
      body: FutureBuilder<OrderModel?>(
        future: _orderDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat detail pesanan.', style: TextStyle(color: AppColors.textGrey)));
          }

          final order = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status & Info Utama
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status.toUpperCase(),
                          style: TextStyle(color: _getStatusColor(order.status), fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text('Order ID: #${order.shortOrderId}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      const SizedBox(height: 4),
                      Text('Placed on ${Formatters.formatDate(order.orderDate)}', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Shipping Address & Notes
                const Text('SHIPPING INFO', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined, color: isDark ? AppColors.accentPeach : AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(order.shippingAddress, style: TextStyle(color: textColor, height: 1.5))),
                        ],
                      ),
                      if (order.notes != null && order.notes!.isNotEmpty) ...[
                        Divider(height: 24, color: dividerColor),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.note_alt_outlined, color: Colors.orange, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text('Notes: ${order.notes}', style: TextStyle(color: textColor, fontStyle: FontStyle.italic))),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Ordered Items
                const Text('ORDERED ITEMS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textGrey)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      if (order.items.isEmpty) 
                         const Padding(padding: EdgeInsets.all(8.0), child: Text('Detail barang tidak tersedia dari API.', style: TextStyle(color: AppColors.textGrey, fontStyle: FontStyle.italic))),
                         
                      ...order.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                    Text('${item.quantity} x ${Formatters.formatRupiah(item.unitPrice)}', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Text(
                                Formatters.formatRupiah(item.subtotal > 0 ? item.subtotal : (item.quantity * item.unitPrice)), 
                                style: TextStyle(fontWeight: FontWeight.bold, color: textColor)
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      Divider(height: 24, color: dividerColor),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Grand Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                          Text(Formatters.formatRupiah(order.totalPrice), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.accentPeach : AppColors.primary, fontSize: 18)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}