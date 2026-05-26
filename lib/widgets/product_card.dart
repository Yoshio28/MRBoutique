// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';
import 'model_detail_sheet.dart';

class ProductCard extends StatelessWidget {
  final ProductData product;
  final bool isDark;

  const ProductCard({
    super.key,
    required this.product,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showProductDetail(context, product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppTheme.getBackground(isDark),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.image_rounded,
                    color: AppTheme.getTextSecondary(isDark),
                    size: 40,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Consumer<WishlistProvider>(
                      builder: (context, wishlist, _) {
                        final isInWishlist = wishlist.isInWishlist(product.id);
                        return GestureDetector(
                          onTap: () {
                            wishlist.toggleItem(
                              WishlistItem(
                                id: product.id,
                                name: product.name,
                                price: product.price,
                                image: product.image,
                                colors: product.colors,
                              ),
                            );
                          },
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppTheme.getSurface(isDark),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Icon(
                              isInWishlist
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_outline_rounded,
                              color: isInWishlist
                                  ? AppTheme.error
                                  : AppTheme.getTextSecondary(isDark),
                              size: 18,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Colores
                  SizedBox(
                    height: 24,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.colors.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Color(
                                int.parse(
                                  product.colors[index]
                                      .replaceFirst('#', '0xFF'),
                                ),
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.getBorder(isDark),
                                width: 1.5,
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
          ],
        ),
      ),
    );
  }
}
