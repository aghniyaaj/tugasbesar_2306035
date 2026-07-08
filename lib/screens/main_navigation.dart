import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Tambahkan ini
import '../providers/theme_provider.dart'; // Tambahkan ini
import '../utils/constants.dart';
import 'home/home_screen.dart';
import 'cart/cart_screen.dart';
import 'wishlist/wishlist_screen.dart'; 
import 'order/order_history_screen.dart';
import 'profile/profile_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  late final List<Widget> _screens = [
    HomeScreen(onProfileTapped: () => _onItemTapped(4)), 
    const WishlistScreen(),
    const CartScreen(),
    const OrderHistoryScreen(),
    // FITUR BARU: Mengirim fungsi pindah tab ke ProfileScreen
    ProfileScreen(
      onNavigateToWishlist: () => _onItemTapped(1), 
      onNavigateToOrders: () => _onItemTapped(3),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Deteksi Tema
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    final navBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final unselectedColor = isDark ? Colors.grey.shade600 : Colors.grey.shade400;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: unselectedColor, // Dinamis
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: navBgColor, // Dinamis
        elevation: isDark ? 0 : 8,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined), label: 'Orders'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}