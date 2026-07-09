/// Model yang merepresentasikan data riwayat pesanan (Order).
class OrderModel {
  /// ID dari pesanan.
  final String id;
  /// Tanggal pesanan dibuat.
  final String orderDate;
  /// Total harga dari pesanan.
  final double totalPrice;
  /// Status dari pesanan (contoh: Pending, Completed).
  final String status;
  /// Alamat pengiriman untuk pesanan ini.
  final String shippingAddress;
  /// Catatan tambahan untuk pesanan.
  final String? notes;
  /// Daftar item yang ada dalam pesanan.
  final List<OrderItemModel> items;

  /// Konstruktor untuk menginisialisasi objek [OrderModel].
  OrderModel({
    required this.id,
    required this.orderDate,
    required this.totalPrice,
    required this.status,
    required this.shippingAddress,
    this.notes,
    required this.items,
  });

  /// Getter untuk mengambil 8 karakter pertama dari UUID pesanan.
  String get shortOrderId {
    if (id.length >= 8) {
      return id.substring(0, 8).toUpperCase();
    }
    return id.toUpperCase();
  }

  /// Method factory untuk membuat objek [OrderModel] dari data JSON.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Mendeteksi list item dengan berbagai kemungkinan nama
      var itemsList = json['items'] ?? json['order_items'] ?? json['orderItems'] ?? json['products'] ?? json['detail'] ?? [];
      if (itemsList is! List) itemsList = [];
      
      List<OrderItemModel> parsedItems = 
          (itemsList).map((i) => OrderItemModel.fromJson(i)).toList();

      return OrderModel(
        id: json['id']?.toString() ?? json['_id']?.toString() ?? 'UNKNOWN_ID',
        orderDate: json['orderDate']?.toString() ?? json['order_date']?.toString() ?? json['createdAt']?.toString() ?? json['created_at']?.toString() ?? '-',
        // PENGAMAN HARGA: Mendeteksi berbagai macam nama kunci harga
        totalPrice: double.tryParse(json['totalPrice']?.toString() ?? json['total_price']?.toString() ?? json['total_amount']?.toString() ?? json['grand_total']?.toString() ?? '0') ?? 0.0,
        status: json['status']?.toString() ?? 'Pending',
        shippingAddress: json['shippingAddress']?.toString() ?? json['shipping_address']?.toString() ?? json['address']?.toString() ?? '-',
        notes: json['notes']?.toString(),
        items: parsedItems,
      );
    } catch (e) {
      print("🚨 [ERROR PARSING ORDER JSON]: $e");
      rethrow;
    }
  }
}

/// Model yang merepresentasikan item di dalam sebuah pesanan.
class OrderItemModel {
  /// Nama dari produk.
  final String productName;
  /// Jumlah produk yang dipesan.
  final int quantity;
  /// Harga satuan dari produk.
  final double unitPrice;
  /// Subtotal harga (kuantitas * harga satuan).
  final double subtotal;

  /// Konstruktor untuk menginisialisasi objek [OrderItemModel].
  OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  /// Method factory untuk membuat objek [OrderItemModel] dari data JSON.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? json['product']?['name']?.toString() ?? json['name']?.toString() ?? 'Unknown Product',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? json['unit_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}