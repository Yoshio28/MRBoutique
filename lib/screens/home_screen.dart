// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<ProductData> _recentProducts = const [
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
      id: '2',
      name: 'Camisa Casual',
      price: 35.99,
      image: 'assets/images/camisa1.png',
      colors: ['#1E90FF', '#4169E1', '#000000'],
      category: 'Camisas',
      stock: 20,
    ),
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
      id: '4',
      name: 'Falda Plisada',
      price: 39.99,
      image: 'assets/images/falda1.png',
      colors: ['#2F4F4F', '#696969', '#A9A9A9'],
      category: 'Faldas',
      stock: 12,
    ),
  ];

  final List<ProductData> _popularProducts = const [
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
      id: '6',
      name: 'Vestido Floral',
      price: 65.99,
      image: 'assets/images/vestido1.png',
      colors: ['#FF69B4', '#FFB6C1', '#FFC0CB'],
      category: 'Vestidos',
      stock: 8,
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
    ProductData(
      id: '8',
      name: 'Camisa Denim',
      price: 52.99,
      image: 'assets/images/camisa2.png',
      colors: ['#1E90FF', '#4169E1', '#87CEEB'],
      category: 'Camisas',
      stock: 16,
    ),
  ];

  final List<ProductData> _recommendedProducts = const [
    ProductData(
      id: '9',
      name: 'Conjunto Elegante',
      price: 75.99,
      image: 'assets/images/conjunto2.png',
      colors: ['#000000', '#2F4F4F', '#696969'],
      category: 'Conjuntos',
      stock: 6,
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
    ProductData(
      id: '11',
      name: 'Pantalón Wide Leg',
      price: 54.99,
      image: 'assets/images/pantalon2.png',
      colors: ['#FFFFFF', '#F5F5F5', '#DCDCDC'],
      category: 'Pantalones',
      stock: 9,
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Delegate de grid reutilizable con el ratio corregido
  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.78, // ✅ Antes 0.85 → causaba overflow; ahora hay espacio suficiente
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de búsqueda
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceCard(isDark),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.getBorder(isDark)),
            ),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    color: AppTheme.getTextSecondary(isDark), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      hintStyle:
                          TextStyle(color: AppTheme.getTextSecondary(isDark)),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recientes
          _SectionTitle(title: 'Recientes', isDark: isDark),
          const SizedBox(height: 14),
          SizedBox(
            height: 220,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _recentProducts.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: SizedBox(
                  width: 155,
                  child: ProductCard(
                    product: _recentProducts[index],
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Populares
          _SectionTitle(title: 'Populares', isDark: isDark),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _gridDelegate,
            itemCount: _popularProducts.length,
            itemBuilder: (context, index) => ProductCard(
              product: _popularProducts[index],
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 28),

          // Recomendaciones
          _SectionTitle(title: 'Recomendaciones', isDark: isDark),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: _gridDelegate,
            itemCount: _recommendedProducts.length,
            itemBuilder: (context, index) => ProductCard(
              product: _recommendedProducts[index],
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ✅ Widget auxiliar para títulos de sección
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: AppTheme.getTextPrimary(isDark),
        fontWeight: FontWeight.w700,
        fontSize: 18,
      ),
    );
  }
}

class ProductData {
  final String id;
  final String name;
  final double price;
  final String image;
  final List<String> colors;
  final String category;
  final int stock;

  const ProductData({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.colors,
    required this.category,
    required this.stock,
  });
}
