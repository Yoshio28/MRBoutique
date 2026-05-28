// lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _categorias = [];
  bool _loading = true;
  String? _error;

  static const _colors = [
    Color(0xFF00D4FF), Color(0xFF10B981), Color(0xFF7C3AED),
    Color(0xFFEC4899), Color(0xFFF59E0B), Color(0xFFFF6B6B),
    Color(0xFF6366F1), Color(0xFF14B8A6),
  ];

  // Imagen estática por categoría
  static const _imagenesCategorias = {
    'Blusas':     'lib/assets/product/Categoria/blusas.png',
    'Camisas':    'lib/assets/product/Categoria/camisas.png',
    'Conjuntos':  'lib/assets/product/Categoria/conjunto Completo.png',
    'Faldas':     'lib/assets/product/Categoria/faldas.png',
    'Pantalones': 'lib/assets/product/Categoria/pantalones.png',
    'Vestidos':   'lib/assets/product/Categoria/vestido_noche.png',
  };

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  Future<void> _loadCategorias() async {
    if (!mounted) return;
    setState(() { _loading = true; _error = null; });

    try {
      final snap = await _firestore
          .collection('productos_admin')
          .where('isActive', isEqualTo: true)
          .get();

      final counts = <String, int>{};
      for (final doc in snap.docs) {
        final cat = doc.data()['category'] as String? ?? '';
        if (cat.isNotEmpty) counts[cat] = (counts[cat] ?? 0) + 1;
      }

      final cats = counts.entries.map((e) => {
        'name':  e.key,
        'count': e.value,
      }).toList()
        ..sort((a, b) =>
            (a['name'] as String).compareTo(b['name'] as String));

      if (!mounted) return;
      setState(() { _categorias = cats; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = 'Error al cargar categorías: $e'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_rounded,
                  size: 64, color: AppTheme.getTextSecondary(isDark)),
              const SizedBox(height: 16),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark), fontSize: 14)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadCategorias,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black),
              ),
            ],
          ),
        ),
      );
    }

    if (_categorias.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.category_outlined,
              size: 72, color: AppTheme.getTextSecondary(isDark)),
          const SizedBox(height: 16),
          Text('No hay categorías disponibles',
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.w600,
                  fontSize: 16)),
        ]),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: _categorias.length,
        itemBuilder: (context, i) {
          final cat   = _categorias[i];
          final color = _colors[i % _colors.length];
          final name  = cat['name']  as String;
          final count = cat['count'] as int;
          final asset = _imagenesCategorias[name] ?? '';

          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CategoryProductsScreen(categoryName: name),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceCard(isDark),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.getBorder(isDark)),
              ),
              child: Column(
                children: [
                  // Imagen de la categoría
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16)),
                      child: asset.isNotEmpty
                          ? Image.asset(
                              asset,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _CategoryIcon(color: color),
                            )
                          : _CategoryIcon(color: color),
                    ),
                  ),
                  // Nombre y conteo
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                              color: AppTheme.getTextPrimary(isDark),
                              fontWeight: FontWeight.w700,
                              fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$count producto${count == 1 ? '' : 's'}',
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final Color color;
  const _CategoryIcon({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        color: color.withOpacity(0.12),
        child: Center(
          child: Icon(Icons.checkroom_rounded, color: color, size: 48),
        ),
      );
}