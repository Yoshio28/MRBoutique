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
      onTap: () => showProductDetail(context, product),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Imagen del producto ──────────────────────────────────────
            Expanded(
              flex: 5,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Imagen principal
                    product.image.isNotEmpty
                        ? Image.asset(
                            product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _Placeholder(isDark: isDark),
                          )
                        : _Placeholder(isDark: isDark),

                    // Botón favorito
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Consumer<WishlistProvider>(
                        builder: (context, wishlist, _) {
                          final isInWishlist =
                              wishlist.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () => wishlist.toggleItem(
                              WishlistItem(
                                id: product.id,
                                name: product.name,
                                price: product.price,
                                image: product.image,
                                colors: product.colors,
                              ),
                            ),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.getSurface(isDark)
                                    .withOpacity(0.85),
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
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Info del producto ────────────────────────────────────────
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Nombre
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    // Precio
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    // Colores
                    SizedBox(
                      height: 18,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: product.colors.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Container(
                            width: 16,
                            height: 16,
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
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Placeholder cuando no hay imagen ────────────────────────────────────────

class _Placeholder extends StatelessWidget {
  final bool isDark;
  const _Placeholder({required this.isDark});

  @override
  Widget build(BuildContext context) => Container(
        color: AppTheme.getBackground(isDark),
        child: Center(
          child: Icon(
            Icons.checkroom_rounded,
            color: AppTheme.accent.withOpacity(0.4),
            size: 48,
          ),
        ),
      );
}