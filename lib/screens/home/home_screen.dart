import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../product/product_detail_screen.dart';
import '../../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTapped; // Menerima perintah pindah tab
  
  const HomeScreen({Key? key, this.onProfileTapped}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _limit = 10; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchCategories();
      productProvider.fetchProducts();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // Tunggu proses ambil profil selesai agar kita dapat ID User
      await authProvider.fetchProfile(); 
      
      if (authProvider.user != null) {
        // PERINTAH BUKA LACI KHUSUS SESUAI ID USER!
        Provider.of<WishlistProvider>(context, listen: false).loadWishlist(authProvider.user!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // Sekarang error API sudah diobati, namamu pasti akan muncul!
    final userName = authProvider.user?.fullName.split(' ').first ?? 'User';
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Welcome,', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            Text(userName, style: const TextStyle(fontSize: 20, color: AppColors.textDark, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textDark),
            onPressed: () {}, 
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                // Berpindah ke tab Profile di Navigation Bar bawah
                if (widget.onProfileTapped != null) {
                  widget.onProfileTapped!();
                }
              },
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 16,
                child: Text(userInitial, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
          )
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, productProvider, child) {
          
          // Filter lokal untuk menyembunyikan yang berbeda kategori
          List<dynamic> displayList = productProvider.products;
          if (productProvider.currentCategory != 'All') {
            displayList = displayList.where((p) => 
              p.category.toLowerCase() == productProvider.currentCategory.toLowerCase()
            ).toList();
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onSubmitted: (value) => productProvider.fetchProducts(search: value),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: productProvider.categories.map((category) {
                        return _buildCategoryChip(category, productProvider.currentCategory == category, productProvider);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // BARIS KONTROL SORTING: Kiri (Jumlah), Kanan (Terbaru/Termurah)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // BAGIAN KIRI: Dropdown Jumlah Item (Limit)
                      Row(
                        children: [
                          Text('${displayList.length} items  |  ', style: const TextStyle(color: AppColors.textGrey, fontSize: 12)),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: productProvider.currentLimit,
                              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark, size: 16),
                              style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                              items: const [
                                DropdownMenuItem(value: 10, child: Text('Show 10')),
                                DropdownMenuItem(value: 20, child: Text('Show 20')),
                                DropdownMenuItem(value: 50, child: Text('Show 50')),
                              ],
                              onChanged: (value) {
                                if (value != null) productProvider.fetchProducts(limit: value);
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      // BAGIAN KANAN: Dropdown Urutan (Sort)
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: productProvider.currentSort,
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textDark, size: 16),
                          style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 12),
                          items: const [
                            DropdownMenuItem(value: 'newest', child: Text('Terbaru')),
                            DropdownMenuItem(value: 'price_asc', child: Text('Termurah')),
                            DropdownMenuItem(value: 'price_desc', child: Text('Termahal')),
                          ],
                          onChanged: (value) {
                            if (value != null) productProvider.fetchProducts(sort: value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  productProvider.isLoading 
                    ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary)))
                    : displayList.isEmpty 
                        ? const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Tidak ada produk di kategori ini.", style: TextStyle(color: AppColors.textGrey))))
                        : GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(), 
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.65, 
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: displayList.length,
                            itemBuilder: (context, index) {
                              final product = displayList[index];
                              return ProductCard(
                                product: product,
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)));
                                }
                              );
                            },
                          ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildCategoryChip(String title, bool isSelected, ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: GestureDetector(
        onTap: () => provider.fetchProducts(category: title),
        child: Chip(
          label: Text(title),
          backgroundColor: isSelected ? AppColors.primary : Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : AppColors.textDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.transparent)),
        ),
      ),
    );
  }
}