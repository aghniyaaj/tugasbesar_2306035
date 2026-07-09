import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import 'order_detail_screen.dart'; 

/// Kelas ini merupakan layar untuk menampilkan riwayat pesanan pengguna.
class OrderHistoryScreen extends StatefulWidget {
  /// Konstruktor untuk membuat [OrderHistoryScreen].
  const OrderHistoryScreen({Key? key}) : super(key: key);

  /// Method untuk membuat state dari [OrderHistoryScreen].
  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

/// State untuk [OrderHistoryScreen].
class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  /// Method untuk inisialisasi state, memanggil provider untuk mengambil riwayat pesanan.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token != null) {
        Provider.of<OrderProvider>(context, listen: false).fetchOrders(token);
      }
    });
  }

  /// Method untuk mendapatkan warna berdasarkan status pesanan.
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

  /// Method untuk membangun UI layar riwayat pesanan.
  @override
  Widget build(BuildContext context) {
    // DETEKSI TEMA
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order History', style: TextStyle(fontFamily: 'Serif', color: textColor, fontWeight: .bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          
          if (orderProvider.orders.isEmpty) {
            if (orderProvider.errorMessage != null) {
              final token = Provider.of<AuthProvider>(context, listen: false).token;
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                    const SizedBox(height: 16),
                    Text(orderProvider.errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => orderProvider.fetchOrders(token!),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                    )
                  ],
                ),
              );
            }

            return const Center(child: Text('Belum ada pesanan.', style: TextStyle(color: AppColors.textGrey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderProvider.orders.length,
            itemBuilder: (context, index) {
              final order = orderProvider.orders[index];
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(
                      builder: (context) => OrderDetailScreen(orderId: order.id),
                    )
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor, // WARNA DINAMIS
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('#${order.shortOrderId}', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: TextStyle(color: _getStatusColor(order.status), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(Formatters.formatDate(order.orderDate), style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                      Divider(height: 24, color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Lihat Detail ➔', style: TextStyle(color: AppColors.textGrey, fontSize: 12, fontWeight: FontWeight.bold)),
                          Text(Formatters.formatRupiah(order.totalPrice), style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.accentPeach : AppColors.primary)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}