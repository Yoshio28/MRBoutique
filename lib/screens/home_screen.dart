// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';

// ─── ProductData ──────────────────────────────────────────────────────────────

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

  factory ProductData.fromMap(Map<String, dynamic> map, String docId) {
    return ProductData(
      id:       docId,
      name:     map['name']     as String? ?? '',
      price:    (map['price']   as num?)?.toDouble() ?? 0.0,
      image:    _assetForProduct(
        sku: map['sku'] as String? ?? '',
        name: map['name'] as String? ?? '',
      ),
      colors:   const ['#00D4FF'],
      category: map['category'] as String? ?? '',
      stock:    (map['stock']   as num?)?.toInt() ?? 0,
    );
  }

  static String _assetForProduct({required String sku, required String name}) {
    const skuMap = {
      'BLU-ENC-001': 'lib/assets/product/blusa_encaje.png',
      'BLU-SED-002': 'lib/assets/product/blusa_seda.png',
      'CAM-LIN-001': 'lib/assets/product/linoBlanca.png',
      'CAM-SAT-002': 'lib/assets/product/camisa_corta.png',
      'CON-COS-001': 'lib/assets/product/Conjunto_cosplay.png',
      'CON-ESC-002': 'lib/assets/product/Conjunto_Escolar_Gothic.png',
      'CON-GOT-003': 'lib/assets/product/conjunto_goth.jpg',
      'CON-TOP-004': 'lib/assets/product/Conjunto_top.png',
      'FAL-MEZ-001': 'lib/assets/product/falda_mezclilla.png',
      'FAL-NEG-002': 'lib/assets/product/falda_negra.png',
      'PAN-MEZ-001': 'lib/assets/product/pantalon_Mezcilla.png',
      'PAN-VES-002': 'lib/assets/product/pantalon_vestir.png',
      'VES-FLO-001': 'lib/assets/product/vestido_floral.png',
      'VES-NOC-002': 'lib/assets/product/vestido_noche.png',
    };

    if (skuMap.containsKey(sku)) {
      return skuMap[sku]!;
    }

    final normalizedName = name.trim().toLowerCase();
    const nameMap = {
      'pantalon de vestir': 'lib/assets/product/pantalon_vestir.png',
      'blusa seda': 'lib/assets/product/blusa_seda.png',
      'pantalon mezclilla': 'lib/assets/product/pantalon_Mezcilla.png',
      'blusa encaje': 'lib/assets/product/blusa_encaje.png',
      'conjunto escolar gothic': 'lib/assets/product/Conjunto_Escolar_Gothic.png',
      'conjunto goth': 'lib/assets/product/conjunto_goth.jpg',
      'camisa corta': 'lib/assets/product/camisa_corta.png',
      'falda negra': 'lib/assets/product/falda_negra.png',
      'conjunto cosplay': 'lib/assets/product/Conjunto_cosplay.png',
    };

    return nameMap[normalizedName] ?? '';
  }
}

// ─── HomeScreen ───────────────────────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();

  List<ProductData> _allProducts = [];
  String _searchQuery = '';
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });

    try {
      final snap = await _firestore
          .collection('productos_admin')
          .where('isActive', isEqualTo: true)
          .get();

      final products = snap.docs
          .map((d) => ProductData.fromMap(d.data(), d.id))
          .toList();

      if (!mounted) return;
      setState(() { _allProducts = products; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error al cargar productos: $e'; _loading = false; });
    }
  }

  bool get _isSearching => _searchQuery.isNotEmpty;

  List<ProductData> get _searchResults {
    if (_searchQuery.isEmpty) return [];
    final q = _searchQuery.toLowerCase();
    return _allProducts.where((p) =>
        p.name.toLowerCase().contains(q) ||
        p.category.toLowerCase().contains(q)).toList();
  }

  List<ProductData> _recent(int n) =>
      _allProducts.reversed.take(n).toList();

  List<ProductData> _popular(int n) =>
      _allProducts.take(n).toList();

  List<ProductData> _recommended(int n) =>
      _allProducts.skip(_popular(n).length).take(n).toList();

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: 12,
    crossAxisSpacing: 12,
    childAspectRatio: 0.78,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _loadData, isDark: isDark);
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Barra de búsqueda ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceCard(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.getBorder(isDark)),
              ),
              child: Row(children: [
                Icon(Icons.search_rounded,
                    color: AppTheme.getTextSecondary(isDark), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) =>
                        setState(() => _searchQuery = v.trim()),
                    onChanged: (v) {
                      if (v.isEmpty) setState(() => _searchQuery = '');
                    },
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
                if (_isSearching)
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                      FocusScope.of(context).unfocus();
                    },
                    child: Icon(Icons.close_rounded,
                        color: AppTheme.getTextSecondary(isDark), size: 20),
                  ),
              ]),
            ),
            const SizedBox(height: 24),

            // ── Vista búsqueda ───────────────────────────────────────────
            if (_isSearching) ...[
              _SectionTitle(
                  title: 'Resultados para "$_searchQuery"', isDark: isDark),
              const SizedBox(height: 4),
              Text(
                '${_searchResults.length} producto${_searchResults.length == 1 ? '' : 's'} encontrado${_searchResults.length == 1 ? '' : 's'}',
                style: TextStyle(
                    color: AppTheme.getTextSecondary(isDark), fontSize: 13),
              ),
              const SizedBox(height: 14),
              if (_searchResults.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Column(children: [
                      Icon(Icons.search_off_rounded,
                          size: 64,
                          color: AppTheme.getTextSecondary(isDark)),
                      const SizedBox(height: 12),
                      Text('Sin resultados',
                          style: TextStyle(
                              color: AppTheme.getTextPrimary(isDark),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 6),
                      Text('Intenta con otro término',
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark),
                              fontSize: 13)),
                    ]),
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: _gridDelegate,
                  itemCount: _searchResults.length,
                  itemBuilder: (_, i) =>
                      ProductCard(product: _searchResults[i], isDark: isDark),
                ),

            // ── Vista normal ─────────────────────────────────────────────
            ] else if (_allProducts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(children: [
                    Icon(Icons.store_outlined,
                        size: 72,
                        color: AppTheme.getTextSecondary(isDark)),
                    const SizedBox(height: 16),
                    Text('No hay productos disponibles',
                        style: TextStyle(
                            color: AppTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.w600,
                            fontSize: 16)),
                  ]),
                ),
              )
            else ...[

              // Recientes
              _SectionTitle(title: 'Recientes', isDark: isDark),
              const SizedBox(height: 14),
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _recent(4).length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 155,
                      child: ProductCard(
                          product: _recent(4)[i], isDark: isDark),
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
                itemCount: _popular(4).length,
                itemBuilder: (_, i) =>
                    ProductCard(product: _popular(4)[i], isDark: isDark),
              ),
              const SizedBox(height: 28),

              // Recomendaciones
              if (_recommended(4).isNotEmpty) ...[
                _SectionTitle(title: 'Recomendaciones', isDark: isDark),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: _gridDelegate,
                  itemCount: _recommended(4).length,
                  itemBuilder: (_, i) =>
                      ProductCard(product: _recommended(4)[i], isDark: isDark),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widgets auxiliares ───────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: TextStyle(
          color: AppTheme.getTextPrimary(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final bool isDark;
  const _ErrorView(
      {required this.message, required this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
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
}