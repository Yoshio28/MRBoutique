// lib/widgets/model_detail_sheet.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../screens/home_screen.dart';

void showProductDetail(BuildContext context, ProductData product) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductDetailSheet(product: product),
  );
}

class _ProductDetailSheet extends StatefulWidget {
  final ProductData product;
  const _ProductDetailSheet({required this.product});

  @override
  State<_ProductDetailSheet> createState() => _ProductDetailSheetState();
}

class _ProductDetailSheetState extends State<_ProductDetailSheet> {
  late String _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors[0];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final user = context.watch<UserProvider>();
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      height: screenH * 0.88,
      decoration: BoxDecoration(
        color: AppTheme.getSurface(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.getBorder(isDark),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview imagen
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: AppTheme.getBackground(isDark),
                      border: Border.all(color: AppTheme.getBorder(isDark)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(Icons.image_rounded,
                            color: AppTheme.getTextSecondary(isDark), size: 60),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Consumer<WishlistProvider>(
                            builder: (context, wishlist, _) {
                              final isInWishlist =
                                  wishlist.isInWishlist(widget.product.id);
                              return GestureDetector(
                                onTap: () {
                                  wishlist.toggleItem(
                                    WishlistItem(
                                      id: widget.product.id,
                                      name: widget.product.name,
                                      price: widget.product.price,
                                      image: widget.product.image,
                                      colors: widget.product.colors,
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.getSurface(isDark),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 12,
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
                                    size: 22,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Nombre y precio
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            color: AppTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${widget.product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Stock
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: widget.product.stock > 5
                              ? AppTheme.success
                              : AppTheme.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Stock: ${widget.product.stock} unidades',
                        style: TextStyle(
                          color: AppTheme.getTextSecondary(isDark),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Seleccionar color
                  Text(
                    'Selecciona un color',
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.product.colors.length,
                      itemBuilder: (context, index) {
                        final color = widget.product.colors[index];
                        final isSelected = _selectedColor == color;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedColor = color),
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(
                                    int.parse(color.replaceFirst('#', '0xFF'))),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.accent
                                      : AppTheme.getBorder(isDark),
                                  width: isSelected ? 3 : 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cantidad
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Cantidad',
                        style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceCard(isDark),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.getBorder(isDark)),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_rounded,
                                  color: AppTheme.getTextPrimary(isDark),
                                  size: 18),
                              onPressed: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Text(
                              '$_quantity',
                              style: TextStyle(
                                color: AppTheme.getTextPrimary(isDark),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_rounded,
                                  color: AppTheme.getTextPrimary(isDark),
                                  size: 18),
                              onPressed: () {
                                if (_quantity < widget.product.stock)
                                  setState(() => _quantity++);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Dirección de entrega
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getSurfaceCard(isDark),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.getBorder(isDark)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded,
                            color: AppTheme.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Entregar en',
                                style: TextStyle(
                                  color: AppTheme.getTextSecondary(isDark),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                user.address.isNotEmpty
                                    ? user.address
                                    : 'Agregar dirección',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: AppTheme.getTextPrimary(isDark),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón añadir al carrito
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        context.read<CartProvider>().addItem(
                              CartItem(
                                id: widget.product.id,
                                name: widget.product.name,
                                price: widget.product.price,
                                image: widget.product.image,
                                color: _selectedColor,
                                quantity: _quantity,
                              ),
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Añadido al carrito'),
                            backgroundColor: AppTheme.success,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accent,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.shopping_bag_rounded),
                      label: const Text(
                        'Añadir al carrito',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
