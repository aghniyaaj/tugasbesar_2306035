import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/review_provider.dart';
import 'providers/theme_provider.dart'; // Tambahkan ini
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'utils/constants.dart';

/// Method utama untuk menjalankan aplikasi Flutter.
void main() {
  runApp(const MyApp());
}

/// Kelas utama aplikasi.
class MyApp extends StatelessWidget {
  /// Konstruktor untuk membuat [MyApp].
  const MyApp({Key? key}) : super(key: key);

  /// Method untuk membangun hirarki UI utama aplikasi, termasuk pengaturan tema dan provider.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()), // Tambahkan ini
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Bloom App',
            debugShowCheckedModeBanner: false,
            // Tema Dinamis
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: AppColors.background,
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primaryColor: AppColors.primary,
              scaffoldBackgroundColor: const Color(0xFF121212),
              cardColor: const Color(0xFF1E1E1E),
              textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}