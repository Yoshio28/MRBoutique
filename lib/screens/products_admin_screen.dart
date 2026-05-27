// lib/screens/products_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

// ─── Modelo ─────

class Product {
  final String id;
  String name;
  String category;
  double price;
  double costPrice;
  int stock;
  String sku;
  bool isActive;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.costPrice,
    required this.stock,
    required this.sku,
    this.isActive = true,
  });

  double get margin => price > 0 ? ((price - costPrice) / price) * 100 : 0;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'costPrice': costPrice,
        'stock': stock,
        'sku': sku,
        'isActive': isActive,
      };

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        price: (j['price'] as num).toDouble(),
        costPrice: (j['costPrice'] as num).toDouble(),
        stock: j['stock'] as int,
        sku: j['sku'] as String,
        isActive: j['isActive'] as bool? ?? true,
      );
}

// ─── Provider ────

class ProductsAdminProvider extends ChangeNotifier {
  static const _kKey = 'products_admin_list';

  final List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  ProductsAdminProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _products.addAll(
            decoded.map((e) => Product.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kKey, jsonEncode(_products.map((e) => e.toJson()).toList()));
  }

  Future<void> addProduct(Product p) async {
    _products.add(p);
    notifyListeners();
    await _save();
  }

  Future<void> updateProduct(Product updated) async {
    final i = _products.indexWhere((p) => p.id == updated.id);
    if (i != -1) {
      _products[i] = updated;
      notifyListeners();
      await _save();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    await _save();
  }
}

// ─── Pantalla ppal

class ProductsAdminScreen extends StatefulWidget {
  const ProductsAdminScreen({super.key});

  @override
  State<ProductsAdminScreen> createState() => _ProductsAdminScreenState();
}

class _ProductsAdminScreenState extends State<ProductsAdminScreen> {
  String _search = '';
  String _filterCat = 'Todas';

  static const _categories = [
    'Todas',
    'Blusas',
    'Camisas',
    'Conjuntos',
    'Faldas',
    'Pantalones',
    'Vestidos',
    'Accesorios',
  ];

  List<Product> _filtered(List<Product> all) {
    return all.where((p) {
      final matchSearch = _search.isEmpty ||
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.sku.toLowerCase().contains(_search.toLowerCase());
      final matchCat = _filterCat == 'Todas' || p.category == _filterCat;
      return matchSearch && matchCat;
    }).toList();
  }

  void _openForm({Product? product}) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final provider = context.read<ProductsAdminProvider>();
    final isEdit = product != null;

    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final priceCtrl = TextEditingController(
        text: product != null ? product.price.toStringAsFixed(2) : '');
    final costCtrl = TextEditingController(
        text: product != null ? product.costPrice.toStringAsFixed(2) : '');
    final stockCtrl = TextEditingController(
        text: product != null ? product.stock.toString() : '');
    String selectedCat = product?.category ?? _categories[1];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceCard(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.getBorder(isDark),
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 20),
                Text(isEdit ? 'Editar producto' : 'Nuevo producto',
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 20)),
                const SizedBox(height: 24),
                _Field(
                    controller: nameCtrl,
                    label: 'Nombre del producto',
                    icon: Icons.inventory_2_outlined,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Field(
                    controller: skuCtrl,
                    label: 'SKU / Código',
                    icon: Icons.qr_code_rounded,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Dropdown(
                  label: 'Categoría',
                  icon: Icons.category_outlined,
                  value: selectedCat,
                  items: _categories.skip(1).toList(),
                  isDark: isDark,
                  onChanged: (v) => setModal(() => selectedCat = v!),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                          controller: priceCtrl,
                          label: 'Precio venta',
                          icon: Icons.sell_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                          controller: costCtrl,
                          label: 'Precio costo',
                          icon: Icons.price_change_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          isDark: isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _Field(
                    controller: stockCtrl,
                    label: 'Stock inicial',
                    icon: Icons.layers_outlined,
                    keyboardType: TextInputType.number,
                    isDark: isDark),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('El nombre es obligatorio'),
                          backgroundColor: AppTheme.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                        return;
                      }
                      final p = Product(
                        id: isEdit
                            ? product!.id
                            : DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        category: selectedCat,
                        price: double.tryParse(priceCtrl.text) ?? 0,
                        costPrice: double.tryParse(costCtrl.text) ?? 0,
                        stock: int.tryParse(stockCtrl.text) ?? 0,
                        sku: skuCtrl.text.trim(),
                        isActive: isEdit ? product!.isActive : true,
                      );
                      if (isEdit) {
                        await provider.updateProduct(p);
                      } else {
                        await provider.addProduct(p);
                      }
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isEdit
                              ? 'Producto actualizado'
                              : 'Producto agregado'),
                          backgroundColor: AppTheme.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(isEdit ? 'Guardar cambios' : 'Agregar producto',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return ChangeNotifierProvider(
      create: (_) => ProductsAdminProvider(),
      child: Consumer<ProductsAdminProvider>(
        builder: (context, provider, _) {
          final list = _filtered(provider.products);

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppTheme.getBackground(isDark),
              body: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceCard(isDark),
                            borderRadius: BorderRadius.circular(14),
                            border:
                                Border.all(color: AppTheme.getBorder(isDark)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded,
                                  color: AppTheme.getTextSecondary(isDark),
                                  size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  style: TextStyle(
                                      color: AppTheme.getTextPrimary(isDark)),
                                  onChanged: (v) => setState(() => _search = v),
                                  decoration: InputDecoration(
                                    hintText: 'Buscar por nombre o SKU...',
                                    hintStyle: TextStyle(
                                        color:
                                            AppTheme.getTextSecondary(isDark)),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 36,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final cat = _categories[i];
                              final isActive = cat == _filterCat;
                              return GestureDetector(
                                onTap: () => setState(() => _filterCat = cat),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppTheme.accent
                                        : AppTheme.getSurfaceCard(isDark),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: isActive
                                            ? AppTheme.accent
                                            : AppTheme.getBorder(isDark)),
                                  ),
                                  child: Text(cat,
                                      style: TextStyle(
                                          color: isActive
                                              ? Colors.black
                                              : AppTheme.getTextSecondary(
                                                  isDark),
                                          fontWeight: isActive
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                          fontSize: 13)),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.inventory_2_outlined,
                                    size: 64,
                                    color: AppTheme.getTextSecondary(isDark)),
                                const SizedBox(height: 12),
                                Text('Sin productos',
                                    style: TextStyle(
                                        color: AppTheme.getTextPrimary(isDark),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16)),
                                const SizedBox(height: 6),
                                Text('Presiona + para agregar',
                                    style: TextStyle(
                                        color:
                                            AppTheme.getTextSecondary(isDark),
                                        fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) => _ProductCard(
                              product: list[i],
                              isDark: isDark,
                              onEdit: () => _openForm(product: list[i]),
                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    backgroundColor:
                                        AppTheme.getSurfaceCard(isDark),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(18)),
                                    title: Text('Eliminar producto',
                                        style: TextStyle(
                                            color:
                                                AppTheme.getTextPrimary(isDark),
                                            fontWeight: FontWeight.w700)),
                                    content: Text(
                                        '¿Deseas eliminar "${list[i].name}"?',
                                        style: TextStyle(
                                            color: AppTheme.getTextSecondary(
                                                isDark))),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, false),
                                        child: Text('Cancelar',
                                            style: TextStyle(
                                                color:
                                                    AppTheme.getTextSecondary(
                                                        isDark))),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, true),
                                        child: const Text('Eliminar',
                                            style: TextStyle(
                                                color: Color(0xFFFCA5A5),
                                                fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await provider.deleteProduct(list[i].id);
                                }
                              },
                            ),
                          ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () => _openForm(),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Nuevo producto',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Card de producto ─────

class _ProductCard extends StatelessWidget {
  final Product product;
  final bool isDark;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ProductCard({
    required this.product,
    required this.isDark,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stock <= 5;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isLowStock
                ? AppTheme.error.withOpacity(0.4)
                : AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          // Ícono de categoría
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.inventory_2_rounded,
                color: AppTheme.accent, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(product.category,
                        style: TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                    if (product.sku.isNotEmpty) ...[
                      Text('  ·  ',
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark))),
                      Text(product.sku,
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark),
                              fontSize: 12)),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: AppTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.w700,
                            fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('${product.margin.toStringAsFixed(0)}% margen',
                        style: TextStyle(
                            color: product.margin >= 30
                                ? AppTheme.success
                                : AppTheme.error,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    const Spacer(),
                    Icon(
                        isLowStock
                            ? Icons.warning_amber_rounded
                            : Icons.layers_rounded,
                        size: 14,
                        color: isLowStock
                            ? AppTheme.error
                            : AppTheme.getTextSecondary(isDark)),
                    const SizedBox(width: 4),
                    Text('${product.stock} pzs',
                        style: TextStyle(
                            color: isLowStock
                                ? AppTheme.error
                                : AppTheme.getTextSecondary(isDark),
                            fontSize: 12,
                            fontWeight: isLowStock
                                ? FontWeight.w700
                                : FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppTheme.getSurfaceCard(isDark),
            icon: Icon(Icons.more_vert_rounded,
                color: AppTheme.getTextSecondary(isDark)),
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(children: [
                  const Icon(Icons.edit_outlined,
                      size: 18, color: AppTheme.accent),
                  const SizedBox(width: 8),
                  Text('Editar',
                      style: TextStyle(color: AppTheme.getTextPrimary(isDark))),
                ]),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  const Icon(Icons.delete_outline_rounded,
                      size: 18, color: Color(0xFFFCA5A5)),
                  const SizedBox(width: 8),
                  const Text('Eliminar',
                      style: TextStyle(color: Color(0xFFFCA5A5))),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets aux ────

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isDark;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: AppTheme.getTextSecondary(isDark)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                dropdownColor: AppTheme.getSurfaceCard(isDark),
                style: TextStyle(
                    color: AppTheme.getTextPrimary(isDark), fontSize: 14),
                isExpanded: true,
                items: items
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
