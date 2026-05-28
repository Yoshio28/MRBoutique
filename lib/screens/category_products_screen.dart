// lib/screens/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'home_screen.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() =>
      _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _firestore = FirebaseFirestore.instance;

  List<ProductData> _products = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });

    try {
      final snap = await _firestore
          .collection('productos_admin')
          .where('category', isEqualTo: widget.categoryName)
          .where('isActive', isEqualTo: true)
          .get();

      final products = snap.docs
          .map((d) => ProductData.fromMap(d.data(), d.id))
          .toList();

      if (!mounted) return;
      setState(() { _products = products; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Error al cargar productos: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

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
          widget.categoryName,
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _ErrorBody(
                  message: _error!,
                  onRetry: _loadProducts,
                  isDark: isDark,
                )
              : _products.isEmpty
                  ? _EmptyBody(isDark: isDark)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        itemCount: _products.length,
                        itemBuilder: (_, i) => ProductCard(
                          product: _products[i],
                          isDark: isDark,
                        ),
                      ),
                    ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _EmptyBody extends StatelessWidget {
  final bool isDark;
  const _EmptyBody({required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 72, color: AppTheme.getTextSecondary(isDark)),
            const SizedBox(height: 16),
            Text(
              'No hay productos en esta categoría',
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 16),
            ),
          ],
        ),
      );
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorBody(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 64, color: AppTheme.getTextSecondary(isDark)),
              const SizedBox(height: 16),
              Text(message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark), fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),
        ),
      );
}