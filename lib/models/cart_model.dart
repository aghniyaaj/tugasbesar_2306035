import 'product_model.dart';

/// Model utama yang membungkus keseluruhan keranjang belanja user.
/// Menampung daftar item dan total harga keseluruhan.
class CartModel {
  /// Daftar barang yang ada di dalam keranjang
  final List<CartItemModel> items;
  
  /// Total harga dari semua barang di keranjang (Grand Total)
  final double grandTotal;

  /// Constructor inisialisasi CartModel
  CartModel({
    required this.items,
    required this.grandTotal,
  });

  /// Mengubah JSON dari API menjadi objek [CartModel]
  factory CartModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];
    List<CartItemModel> parsedItems = 
        itemsList.map((i) => CartItemModel.fromJson(i)).toList();

    return CartModel(
      items: parsedItems,
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
    );
  }
}

/// Model yang merepresentasikan satu baris barang di dalam keranjang.
class CartItemModel {
  /// ID unik item di keranjang (bukan ID produk)
  final String id;
  
  /// Data produk yang dimasukkan ke keranjang
  final ProductModel product;
  
  /// Jumlah kuantitas barang yang dibeli (contoh: 2 buah)
  final int quantity;
  
  /// Total harga untuk item ini (harga produk * kuantitas)
  final double subtotal;

  CartItemModel({
    required this.id,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] ?? '',
      // Memanggil method fromJson dari ProductModel untuk mapping nested object
      product: ProductModel.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 1,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}