// lib/screens/inventory_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class InventoryItem {
  final String id;
  String name;
  String category;
  String sku;
  int stock;
  int minStock;
  int maxStock;
  double costPrice;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.sku,
    required this.stock,
    required this.minStock,
    required this.maxStock,
    required this.costPrice,
  });

  StockStatus get status {
    if (stock <= 0) return StockStatus.empty;
    if (stock <= minStock) return StockStatus.low;
    if (stock >= maxStock) return StockStatus.overstock;
    return StockStatus.ok;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'sku': sku,
        'stock': stock,
        'minStock': minStock,
        'maxStock': maxStock,
        'costPrice': costPrice,
      };

  factory InventoryItem.fromJson(Map<String, dynamic> j) => InventoryItem(
        id: j['id'] as String,
        name: j['name'] as String,
        category: j['category'] as String,
        sku: j['sku'] as String,
        stock: j['stock'] as int,
        minStock: j['minStock'] as int,
        maxStock: j['maxStock'] as int,
        costPrice: (j['costPrice'] as num).toDouble(),
      );
}

enum StockStatus { empty, low, ok, overstock }

class StockMovement {
  final String itemId;
  final String itemName;
  final int quantity;
  final bool isEntry;
  final String reason;
  final String date;

  StockMovement({
    required this.itemId,
    required this.itemName,
    required this.quantity,
    required this.isEntry,
    required this.reason,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'itemName': itemName,
        'quantity': quantity,
        'isEntry': isEntry,
        'reason': reason,
        'date': date,
      };

  factory StockMovement.fromJson(Map<String, dynamic> j) => StockMovement(
        itemId: j['itemId'] as String,
        itemName: j['itemName'] as String,
        quantity: j['quantity'] as int,
        isEntry: j['isEntry'] as bool,
        reason: j['reason'] as String,
        date: j['date'] as String,
      );
}

// ─── Provider ────

class InventoryProvider extends ChangeNotifier {
  static const _kItems = 'inventory_items';
  static const _kMovements = 'inventory_movements';

  final List<InventoryItem> _items = [];
  final List<StockMovement> _movements = [];

  List<InventoryItem> get items => List.unmodifiable(_items);
  List<StockMovement> get movements => List.unmodifiable(_movements);

  InventoryProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawItems = prefs.getString(_kItems);
      if (rawItems != null) {
        final List decoded = jsonDecode(rawItems) as List;
        _items.addAll(decoded
            .map((e) => InventoryItem.fromJson(e as Map<String, dynamic>)));
      }
      final rawMov = prefs.getString(_kMovements);
      if (rawMov != null) {
        final List decodedMov = jsonDecode(rawMov) as List;
        _movements.addAll(decodedMov
            .map((e) => StockMovement.fromJson(e as Map<String, dynamic>)));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(
          _kItems, jsonEncode(_items.map((e) => e.toJson()).toList())),
      prefs.setString(
          _kMovements, jsonEncode(_movements.map((e) => e.toJson()).toList())),
    ]);
  }

  Future<void> addItem(InventoryItem item) async {
    _items.add(item);
    notifyListeners();
    await _save();
  }

  Future<void> adjustStock({
    required String itemId,
    required int quantity,
    required bool isEntry,
    required String reason,
  }) async {
    final i = _items.indexWhere((e) => e.id == itemId);
    if (i == -1) return;
    final item = _items[i];
    item.stock = isEntry
        ? item.stock + quantity
        : (item.stock - quantity).clamp(0, 9999);

    final now = DateTime.now();
    final months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic'
    ];
    _movements.insert(
      0,
      StockMovement(
        itemId: itemId,
        itemName: item.name,
        quantity: quantity,
        isEntry: isEntry,
        reason: reason,
        date: '${now.day} ${months[now.month - 1]} ${now.year}, '
            '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
    );
    notifyListeners();
    await _save();
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _save();
  }

  int get totalUnits => _items.fold(0, (s, i) => s + i.stock);
  double get totalValue => _items.fold(0, (s, i) => s + i.stock * i.costPrice);
  int get lowStockCount =>
      _items.where((i) => i.status == StockStatus.low).length;
  int get emptyCount =>
      _items.where((i) => i.status == StockStatus.empty).length;
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  String _search = '';
  String _filterStatus = 'Todos';

  static const _statusFilters = ['Todos', 'OK', 'Bajo', 'Agotado', 'Exceso'];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  List<InventoryItem> _filtered(List<InventoryItem> all) {
    return all.where((item) {
      final matchSearch = _search.isEmpty ||
          item.name.toLowerCase().contains(_search.toLowerCase()) ||
          item.sku.toLowerCase().contains(_search.toLowerCase());
      final matchStatus = _filterStatus == 'Todos' ||
          (_filterStatus == 'OK' && item.status == StockStatus.ok) ||
          (_filterStatus == 'Bajo' && item.status == StockStatus.low) ||
          (_filterStatus == 'Agotado' && item.status == StockStatus.empty) ||
          (_filterStatus == 'Exceso' && item.status == StockStatus.overstock);
      return matchSearch && matchStatus;
    }).toList();
  }

  void _openAddItem() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final provider = context.read<InventoryProvider>();

    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final stockCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '5');
    final maxCtrl = TextEditingController(text: '100');
    final costCtrl = TextEditingController();
    String selectedCat = 'Blusas';
    const cats = [
      'Blusas',
      'Camisas',
      'Conjuntos',
      'Faldas',
      'Pantalones',
      'Vestidos',
      'Accesorios'
    ];

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
                Text('Agregar al inventario',
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 20)),
                const SizedBox(height: 24),
                _Field(
                    controller: nameCtrl,
                    label: 'Nombre del artículo',
                    icon: Icons.inventory_2_outlined,
                    isDark: isDark),
                const SizedBox(height: 14),
                _Field(
                    controller: skuCtrl,
                    label: 'SKU / Código',
                    icon: Icons.qr_code_rounded,
                    isDark: isDark),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Categoría',
                  icon: Icons.category_outlined,
                  value: selectedCat,
                  items: cats,
                  isDark: isDark,
                  onChanged: (v) => setModal(() => selectedCat = v!),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                          controller: stockCtrl,
                          label: 'Stock actual',
                          icon: Icons.layers_outlined,
                          keyboardType: TextInputType.number,
                          isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                          controller: costCtrl,
                          label: 'Costo unitario',
                          icon: Icons.price_change_outlined,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          isDark: isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _Field(
                          controller: minCtrl,
                          label: 'Stock mínimo',
                          icon: Icons.arrow_downward_rounded,
                          keyboardType: TextInputType.number,
                          isDark: isDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                          controller: maxCtrl,
                          label: 'Stock máximo',
                          icon: Icons.arrow_upward_rounded,
                          keyboardType: TextInputType.number,
                          isDark: isDark),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameCtrl.text.isEmpty) return;
                      await provider.addItem(InventoryItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameCtrl.text.trim(),
                        category: selectedCat,
                        sku: skuCtrl.text.trim(),
                        stock: int.tryParse(stockCtrl.text) ?? 0,
                        minStock: int.tryParse(minCtrl.text) ?? 5,
                        maxStock: int.tryParse(maxCtrl.text) ?? 100,
                        costPrice: double.tryParse(costCtrl.text) ?? 0,
                      ));
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Agregar artículo',
                        style: TextStyle(
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

  void _openAdjustStock(InventoryItem item) {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final provider = context.read<InventoryProvider>();
    final qtyCtrl = TextEditingController();
    bool isEntry = true;
    String reason = 'Reabastecimiento';
    const reasons = [
      'Reabastecimiento',
      'Venta',
      'Devolución',
      'Ajuste de inventario',
      'Merma / Daño',
      'Otro',
    ];

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
                Text('Ajustar stock',
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 20)),
                const SizedBox(height: 4),
                Text(item.name,
                    style: TextStyle(
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 20),
                // Entrada / Salida toggle
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.getBackground(isDark),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.getBorder(isDark)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModal(() => isEntry = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isEntry
                                  ? AppTheme.success.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline_rounded,
                                    color: isEntry
                                        ? AppTheme.success
                                        : AppTheme.getTextSecondary(isDark),
                                    size: 18),
                                const SizedBox(width: 6),
                                Text('Entrada',
                                    style: TextStyle(
                                        color: isEntry
                                            ? AppTheme.success
                                            : AppTheme.getTextSecondary(isDark),
                                        fontWeight: isEntry
                                            ? FontWeight.w700
                                            : FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setModal(() => isEntry = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !isEntry
                                  ? AppTheme.error.withOpacity(0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.remove_circle_outline_rounded,
                                    color: !isEntry
                                        ? AppTheme.error
                                        : AppTheme.getTextSecondary(isDark),
                                    size: 18),
                                const SizedBox(width: 6),
                                Text('Salida',
                                    style: TextStyle(
                                        color: !isEntry
                                            ? AppTheme.error
                                            : AppTheme.getTextSecondary(isDark),
                                        fontWeight: !isEntry
                                            ? FontWeight.w700
                                            : FontWeight.w500)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _Field(
                    controller: qtyCtrl,
                    label: 'Cantidad',
                    icon: Icons.numbers_rounded,
                    keyboardType: TextInputType.number,
                    isDark: isDark),
                const SizedBox(height: 14),
                _DropdownField(
                  label: 'Motivo',
                  icon: Icons.comment_outlined,
                  value: reason,
                  items: reasons,
                  isDark: isDark,
                  onChanged: (v) => setModal(() => reason = v!),
                ),
                const SizedBox(height: 8),
                Text('Stock actual: ${item.stock} pzs',
                    style: TextStyle(
                        color: AppTheme.getTextSecondary(isDark),
                        fontSize: 13)),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final qty = int.tryParse(qtyCtrl.text) ?? 0;
                      if (qty <= 0) return;
                      await provider.adjustStock(
                        itemId: item.id,
                        quantity: qty,
                        isEntry: isEntry,
                        reason: reason,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(isEntry
                              ? 'Entrada registrada: +$qty pzs'
                              : 'Salida registrada: -$qty pzs'),
                          backgroundColor:
                              isEntry ? AppTheme.success : AppTheme.error,
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
                    child: const Text('Registrar movimiento',
                        style: TextStyle(
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
      create: (_) => InventoryProvider(),
      child: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          final filtered = _filtered(provider.items);

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppTheme.getBackground(isDark),
              body: Column(
                children: [
                  // ── Resumen ──────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _StatCard(
                              label: 'Total unidades',
                              value: '${provider.totalUnits}',
                              icon: Icons.layers_rounded,
                              color: AppTheme.accent,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Valor inventario',
                              value:
                                  '\$${provider.totalValue.toStringAsFixed(0)}',
                              icon: Icons.attach_money_rounded,
                              color: AppTheme.success,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _StatCard(
                              label: 'Stock bajo',
                              value: '${provider.lowStockCount}',
                              icon: Icons.warning_amber_rounded,
                              color: const Color(0xFFF59E0B),
                              isDark: isDark,
                            ),
                            const SizedBox(width: 10),
                            _StatCard(
                              label: 'Agotados',
                              value: '${provider.emptyCount}',
                              icon: Icons.remove_shopping_cart_rounded,
                              color: AppTheme.error,
                              isDark: isDark,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Tabs
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceCard(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: AppTheme.getBorder(isDark)),
                          ),
                          child: TabBar(
                            controller: _tabCtrl,
                            indicator: BoxDecoration(
                              color: AppTheme.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: Colors.black,
                            unselectedLabelColor:
                                AppTheme.getTextSecondary(isDark),
                            labelStyle: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 13),
                            tabs: const [
                              Tab(text: 'Artículos'),
                              Tab(text: 'Movimientos'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),

                  Expanded(
                    child: TabBarView(
                      controller: _tabCtrl,
                      children: [
                        // ── Tab 1: Artículos ─────────────────────────────
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getSurfaceCard(isDark),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppTheme.getBorder(isDark)),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.search_rounded,
                                            color: AppTheme.getTextSecondary(
                                                isDark),
                                            size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: TextField(
                                            style: TextStyle(
                                                color: AppTheme.getTextPrimary(
                                                    isDark)),
                                            onChanged: (v) =>
                                                setState(() => _search = v),
                                            decoration: InputDecoration(
                                              hintText: 'Buscar artículo...',
                                              hintStyle: TextStyle(
                                                  color:
                                                      AppTheme.getTextSecondary(
                                                          isDark)),
                                              border: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    height: 34,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _statusFilters.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(width: 8),
                                      itemBuilder: (_, i) {
                                        final f = _statusFilters[i];
                                        final active = f == _filterStatus;
                                        return GestureDetector(
                                          onTap: () =>
                                              setState(() => _filterStatus = f),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 7),
                                            decoration: BoxDecoration(
                                              color: active
                                                  ? AppTheme.accent
                                                  : AppTheme.getSurfaceCard(
                                                      isDark),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: active
                                                      ? AppTheme.accent
                                                      : AppTheme.getBorder(
                                                          isDark)),
                                            ),
                                            child: Text(f,
                                                style: TextStyle(
                                                    color: active
                                                        ? Colors.black
                                                        : AppTheme
                                                            .getTextSecondary(
                                                                isDark),
                                                    fontWeight: active
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    fontSize: 12)),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: filtered.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.warehouse_outlined,
                                              size: 64,
                                              color: AppTheme.getTextSecondary(
                                                  isDark)),
                                          const SizedBox(height: 12),
                                          Text('Sin artículos',
                                              style: TextStyle(
                                                  color:
                                                      AppTheme.getTextPrimary(
                                                          isDark),
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16)),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 4, 20, 100),
                                      itemCount: filtered.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 10),
                                      itemBuilder: (_, i) => _InventoryCard(
                                        item: filtered[i],
                                        isDark: isDark,
                                        onAdjust: () =>
                                            _openAdjustStock(filtered[i]),
                                        onDelete: () async {
                                          final confirm =
                                              await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor:
                                                  AppTheme.getSurfaceCard(
                                                      isDark),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18)),
                                              title: Text('Eliminar artículo',
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .getTextPrimary(
                                                              isDark),
                                                      fontWeight:
                                                          FontWeight.w700)),
                                              content: Text(
                                                  '¿Eliminar "${filtered[i].name}" del inventario?',
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .getTextSecondary(
                                                              isDark))),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, false),
                                                  child: Text('Cancelar',
                                                      style: TextStyle(
                                                          color: AppTheme
                                                              .getTextSecondary(
                                                                  isDark))),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, true),
                                                  child: const Text('Eliminar',
                                                      style: TextStyle(
                                                          color:
                                                              Color(0xFFFCA5A5),
                                                          fontWeight:
                                                              FontWeight.w700)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await provider
                                                .deleteItem(filtered[i].id);
                                          }
                                        },
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        // ── Tab 2: Movimientos ───────────────────────────
                        provider.movements.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.swap_vert_rounded,
                                        size: 64,
                                        color:
                                            AppTheme.getTextSecondary(isDark)),
                                    const SizedBox(height: 12),
                                    Text('Sin movimientos',
                                        style: TextStyle(
                                            color:
                                                AppTheme.getTextPrimary(isDark),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 12, 20, 100),
                                itemCount: provider.movements.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (_, i) {
                                  final m = provider.movements[i];
                                  return Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: AppTheme.getSurfaceCard(isDark),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: AppTheme.getBorder(isDark)),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: m.isEntry
                                                ? AppTheme.success
                                                    .withOpacity(0.15)
                                                : AppTheme.error
                                                    .withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                              m.isEntry
                                                  ? Icons.add_rounded
                                                  : Icons.remove_rounded,
                                              color: m.isEntry
                                                  ? AppTheme.success
                                                  : AppTheme.error,
                                              size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(m.itemName,
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .getTextPrimary(
                                                              isDark),
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      fontSize: 13)),
                                              const SizedBox(height: 2),
                                              Text(m.reason,
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .getTextSecondary(
                                                              isDark),
                                                      fontSize: 12)),
                                              const SizedBox(height: 2),
                                              Text(m.date,
                                                  style: TextStyle(
                                                      color: AppTheme
                                                          .getTextSecondary(
                                                              isDark),
                                                      fontSize: 11)),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '${m.isEntry ? '+' : '-'}${m.quantity} pzs',
                                          style: TextStyle(
                                              color: m.isEntry
                                                  ? AppTheme.success
                                                  : AppTheme.error,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: _openAddItem,
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Agregar artículo',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ───inventario ───────────────────────────────────────────────────────

class _InventoryCard extends StatelessWidget {
  final InventoryItem item;
  final bool isDark;
  final VoidCallback onAdjust;
  final VoidCallback onDelete;

  const _InventoryCard({
    required this.item,
    required this.isDark,
    required this.onAdjust,
    required this.onDelete,
  });

  Color get _statusColor {
    switch (item.status) {
      case StockStatus.ok:
        return AppTheme.success;
      case StockStatus.low:
        return const Color(0xFFF59E0B);
      case StockStatus.empty:
        return AppTheme.error;
      case StockStatus.overstock:
        return const Color(0xFF60A5FA);
    }
  }

  String get _statusLabel {
    switch (item.status) {
      case StockStatus.ok:
        return 'OK';
      case StockStatus.low:
        return 'Bajo';
      case StockStatus.empty:
        return 'Agotado';
      case StockStatus.overstock:
        return 'Exceso';
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct =
        item.maxStock > 0 ? (item.stock / item.maxStock).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: AppTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.w700,
                            fontSize: 14)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(item.category,
                            style: TextStyle(
                                color: AppTheme.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                        if (item.sku.isNotEmpty) ...[
                          Text('  ·  ',
                              style: TextStyle(
                                  color: AppTheme.getTextSecondary(isDark))),
                          Text(item.sku,
                              style: TextStyle(
                                  color: AppTheme.getTextSecondary(isDark),
                                  fontSize: 12)),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(_statusLabel,
                    style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 11)),
              ),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                color: AppTheme.getSurfaceCard(isDark),
                icon: Icon(Icons.more_vert_rounded,
                    color: AppTheme.getTextSecondary(isDark), size: 20),
                onSelected: (v) {
                  if (v == 'adjust') onAdjust();
                  if (v == 'delete') onDelete();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'adjust',
                    child: Row(children: [
                      const Icon(Icons.swap_vert_rounded,
                          size: 18, color: AppTheme.accent),
                      const SizedBox(width: 8),
                      Text('Ajustar stock',
                          style: TextStyle(
                              color: AppTheme.getTextPrimary(isDark))),
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
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppTheme.getBorder(isDark),
                    valueColor: AlwaysStoppedAnimation<Color>(_statusColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text('${item.stock} / ${item.maxStock} pzs',
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark),
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── estado tarjeta ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: AppTheme.getTextSecondary(isDark),
                          fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets aux ─────

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

class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final bool isDark;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
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
