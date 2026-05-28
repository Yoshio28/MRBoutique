// lib/screens/wishlist_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/model_detail_sheet.dart'; // FIX: was 'product_detail_sheet.dart' — matches the actual filename
import 'home_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final wishlist = context.watch<WishlistProvider>();

    return Scaffold(
      backgroundColor: AppTheme.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.getSurface(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppTheme.getTextPrimary(isDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mi Wishlist',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: wishlist.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 80,
                    color: AppTheme.getTextSecondary(isDark),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu wishlist está vacía',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Guarda tus productos favoritos',
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: List.generate(
                  wishlist.items.length,
                  (index) {
                    final item = wishlist.items[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () {
                          showProductDetail(
                            context,
                            ProductData(
                              id: item.id,
                              name: item.name,
                              price: item.price,
                              image: item.image,
                              colors: item.colors,
                              category: '',
                              stock: 10,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceCard(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getBorder(isDark),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Imagen
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: AppTheme.getBackground(isDark),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.image_rounded,
                                  color: AppTheme.getTextSecondary(isDark),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // Detalles
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppTheme.getTextPrimary(isDark),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '\$${item.price.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    SizedBox(
                                      height: 20,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: item.colors.length,
                                        itemBuilder: (context, colorIndex) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(right: 6),
                                            child: Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                color: Color(
                                                  int.parse(
                                                    item.colors[colorIndex]
                                                        .replaceFirst('#', '0xFF'),
                                                  ),
                                                ),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: AppTheme
                                                      .getBorder(isDark),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Botones
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.shopping_bag_rounded,
                                      color: AppTheme.accent,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      context.read<CartProvider>().addItem(
                                            CartItem(
                                              id: item.id,
                                              name: item.name,
                                              price: item.price,
                                              image: item.image,
                                              color: item.colors[0],
                                            ),
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                              'Añadido al carrito'),
                                          backgroundColor: AppTheme.success,
                                          behavior:
                                              SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      );
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: AppTheme.error,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      wishlist.removeItem(item.id);
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 40,
                                      minHeight: 40,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
    );
  }
}
