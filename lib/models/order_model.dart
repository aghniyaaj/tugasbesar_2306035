/// Model yang merepresentasikan data riwayat pesanan (Order).
class OrderModel {
  final String id;
  final String orderDate;
  final double totalPrice;
  final String status;
  final String shippingAddress;
  final String? notes;
  final List<OrderItemModel> items;

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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    try {
      // Mendeteksi list item dengan berbagai kemungkinan nama
      var itemsList = json['items'] ?? json['order_items'] ?? json['orderItems'] ?? json['products'] ?? json['detail'] ?? [];
      if (itemsList is! List) itemsList = [];
      
      List<OrderItemModel> parsedItems = 
          (itemsList as List).map((i) => OrderItemModel.fromJson(i)).toList();

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

class OrderItemModel {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['productName']?.toString() ?? json['product_name']?.toString() ?? json['product']?['name']?.toString() ?? json['name']?.toString() ?? 'Unknown Product',
      quantity: int.tryParse(json['quantity']?.toString() ?? '1') ?? 1,
      unitPrice: double.tryParse(json['unitPrice']?.toString() ?? json['unit_price']?.toString() ?? json['price']?.toString() ?? '0') ?? 0.0,
      subtotal: double.tryParse(json['subtotal']?.toString() ?? '0') ?? 0.0,
    );
  }
}