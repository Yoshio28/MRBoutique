// lib/screens/category_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'home_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryName,
  });

  List<ProductData> _getProductsByCategory(String category) {
    final allProducts = <ProductData>[
      // Blusas
      ProductData(
        id: '1',
        name: 'Blusa Elegante',
        price: 45.99,
        image: 'assets/images/blusa1.png',
        colors: ['#FF6B9D', '#C44569', '#FFFFFF'],
        category: 'Blusas',
        stock: 15,
      ),
      ProductData(
        id: '7',
        name: 'Blusa Transparente',
        price: 42.99,
        image: 'assets/images/blusa2.png',
        colors: ['#000000', '#FFFFFF', '#808080'],
        category: 'Blusas',
        stock: 14,
      ),
      // Camisas
      ProductData(
        id: '2',
        name: 'Camisa Casual',
        price: 35.99,
        image: 'assets/images/camisa1.png',
        colors: ['#1E90FF', '#4169E1', '#000000'],
        category: 'Camisas',
        stock: 20,
      ),
      ProductData(
        id: '8',
        name: 'Camisa Denim',
        price: 52.99,
        image: 'assets/images/camisa2.png',
        colors: ['#1E90FF', '#4169E1', '#87CEEB'],
        category: 'Camisas',
        stock: 16,
      ),
      // Conjuntos
      ProductData(
        id: '3',
        name: 'Conjunto Deportivo',
        price: 55.99,
        image: 'assets/images/conjunto1.png',
        colors: ['#FF1493', '#FFB6C1', '#FFFFFF'],
        category: 'Conjuntos',
        stock: 10,
      ),
      ProductData(
        id: '9',
        name: 'Conjunto Elegante',
        price: 75.99,
        image: 'assets/images/conjunto2.png',
        colors: ['#000000', '#2F4F4F', '#696969'],
        category: 'Conjuntos',
        stock: 6,
      ),
      // Faldas
      ProductData(
        id: '4',
        name: 'Falda Plisada',
        price: 39.99,
        image: 'assets/images/falda1.png',
        colors: ['#2F4F4F', '#696969', '#A9A9A9'],
        category: 'Faldas',
        stock: 12,
      ),
      ProductData(
        id: '10',
        name: 'Falda Midi',
        price: 44.99,
        image: 'assets/images/falda2.png',
        colors: ['#8B4513', '#A0522D', '#CD853F'],
        category: 'Faldas',
        stock: 11,
      ),
      // Pantalones
      ProductData(
        id: '5',
        name: 'Pantalón Skinny',
        price: 49.99,
        image: 'assets/images/pantalon1.png',
        colors: ['#000000', '#1C1C1C', '#2F4F4F'],
        category: 'Pantalones',
        stock: 18,
      ),
      ProductData(
        id: '11',
        name: 'Pantalón Wide Leg',
        price: 54.99,
        image: 'assets/images/pantalon2.png',
        colors: ['#FFFFFF', '#F5F5F5', '#DCDCDC'],
        category: 'Pantalones',
        stock: 9,
      ),
      // Vestidos
      ProductData(
        id: '6',
        name: 'Vestido Floral',
        price: 65.99,
        image: 'assets/images/vestido1.png',
        colors: ['#FF69B4', '#FFB6C1', '#FFC0CB'],
        category: 'Vestidos',
        stock: 8,
      ),
      ProductData(
        id: '12',
        name: 'Vestido Minimalista',
        price: 59.99,
        image: 'assets/images/vestido2.png',
        colors: ['#000000', '#1C1C1C', '#2F4F4F'],
        category: 'Vestidos',
        stock: 13,
      ),
    ];

    return allProducts
        .where((product) => product.category == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final products = _getProductsByCategory(categoryName);

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
          categoryName,
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return ProductCard(
              product: products[index],
              isDark: isDark,
            );
          },
        ),
      ),
    );
  }
}