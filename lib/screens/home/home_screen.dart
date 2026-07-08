import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';
import '../product/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTapped;

  const HomeScreen({Key? key, this.onProfileTapped}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      if (productProvider.categories.isEmpty) {
        productProvider.fetchCategories();
      }
      if (productProvider.products.isEmpty) {
        productProvider.fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final productProvider = Provider.of<ProductProvider>(context);
    
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.textDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Good morning,', style: TextStyle(fontSize: 12, color: AppColors.textGrey)),
            Text(
              user?.fullName.split(' ')[0] ?? 'User',
              style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold, fontFamily: 'Serif'),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: widget.onProfileTapped,
              child: CircleAvatar(
                backgroundColor: AppColors.primary,
                radius: 18,
                backgroundImage: user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: (user?.avatarUrl == null || user!.avatarUrl!.isEmpty)
                    ? Text(
                        user?.fullName.isNotEmpty == true ? user!.fullName[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      )
                    : null,
              ),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await productProvider.fetchProducts();
        },
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  hintStyle: const TextStyle(color: AppColors.textGrey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  productProvider.fetchProducts(search: value);
                },
              ),
              const SizedBox(height: 20),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: productProvider.categories.map((categoryName) {
                    final isSelected = productProvider.currentCategory == categoryName;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(categoryName),
                        selected: isSelected,
                        showCheckmark: false, // 🔥 MEMATIKAN IKON CENTANG 🔥
                        selectedColor: AppColors.primary,
                        backgroundColor: cardColor,
                        labelStyle: TextStyle(
                          color: isSelected 
                              ? Colors.white 
                              : (isDark ? Colors.grey.shade300 : AppColors.textDark),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            productProvider.fetchProducts(category: categoryName);
                          } else {
                            productProvider.fetchProducts(category: 'All'); 
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${productProvider.products.length} items', style: const TextStyle(color: AppColors.textGrey)),
                  PopupMenuButton<String>(
                    child: Row(
                      children: [
                        Text('Sort by: ', style: TextStyle(color: textColor)),
                        Text(
                          productProvider.currentSort,
                          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                        ),
                        Icon(Icons.keyboard_arrow_down, color: textColor, size: 16),
                      ],
                    ),
                    onSelected: (value) {
                      productProvider.fetchProducts(sort: value);
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'newest', child: Text('Newest')),
                      const PopupMenuItem(value: 'price_asc', child: Text('Lowest Price')),
                      const PopupMenuItem(value: 'price_desc', child: Text('Highest Price')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (productProvider.isLoading)
                const Center(child: Padding(padding: EdgeInsets.all(32.0), child: CircularProgressIndicator(color: AppColors.primary)))
              else if (productProvider.products.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.all(32.0), child: Text('Tidak ada produk di kategori ini.', style: TextStyle(color: AppColors.textGrey))))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.65,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: productProvider.products.length,
                  itemBuilder: (context, index) {
                    final product = productProvider.products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Center(child: Icon(Icons.image, color: Colors.grey))),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                                      child: const Icon(Icons.favorite_border, color: AppColors.primary, size: 16),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(product.category.toUpperCase(), style: const TextStyle(fontSize: 9, color: AppColors.textGrey, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.name,
                                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13), 
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    Formatters.formatRupiah(product.price),
                                    style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? AppColors.accentPeach : AppColors.primary, fontSize: 13), 
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}