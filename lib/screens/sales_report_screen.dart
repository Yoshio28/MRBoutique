// lib/screens/sales_report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  String _period = 'Todo';
  static const _periods = ['Hoy', 'Semana', 'Mes', 'Todo'];

  // ── Filtrado por período ──────

  List<Order> _filteredOrders(List<Order> orders) {
    if (_period == 'Todo') return orders;
    final now = DateTime.now();
    return orders.where((o) {
      try {
        final parts = o.date.split(' ');
        final day = int.parse(parts[0]);
        final monthMap = {
          'Enero': 1,
          'Febrero': 2,
          'Marzo': 3,
          'Abril': 4,
          'Mayo': 5,
          'Junio': 6,
          'Julio': 7,
          'Agosto': 8,
          'Septiembre': 9,
          'Octubre': 10,
          'Noviembre': 11,
          'Diciembre': 12,
        };
        final monthStr = parts[2].replaceAll(',', '');
        final month = monthMap[monthStr] ?? now.month;
        final year = int.parse(parts[3]);
        final orderDate = DateTime(year, month, day);
        if (_period == 'Hoy') {
          return orderDate.year == now.year &&
              orderDate.month == now.month &&
              orderDate.day == now.day;
        }
        if (_period == 'Semana') {
          return now.difference(orderDate).inDays <= 7;
        }
        if (_period == 'Mes') {
          return orderDate.year == now.year && orderDate.month == now.month;
        }
      } catch (_) {}
      return true;
    }).toList();
  }

  // ── Métricas ──────

  double _totalRevenue(List<Order> orders) =>
      orders.fold(0.0, (s, o) => s + o.total);

  double _totalSubtotal(List<Order> orders) =>
      orders.fold(0.0, (s, o) => s + o.subtotal);

  double _totalShipping(List<Order> orders) =>
      orders.fold(0.0, (s, o) => s + o.shipping);

  int _totalItems(List<Order> orders) =>
      orders.fold(0, (s, o) => s + o.items.fold(0, (si, i) => si + i.quantity));

  Map<String, double> _byCategory(List<Order> orders) {
    final map = <String, double>{};
    for (final o in orders) {
      for (final item in o.items) {
        map[item.name] = (map[item.name] ?? 0) + item.price * item.quantity;
      }
    }
    return map;
  }

  Map<String, int> _byStatus(List<Order> orders) {
    final map = <String, int>{};
    for (final o in orders) {
      map[o.status] = (map[o.status] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final allOrders = context.watch<OrdersProvider>().orders.toList();
    final orders = _filteredOrders(allOrders);

    final revenue = _totalRevenue(orders);
    final subtotal = _totalSubtotal(orders);
    final shipping = _totalShipping(orders);
    final totalItems = _totalItems(orders);
    final byProduct = _byCategory(orders);
    final byStatus = _byStatus(orders);

    final topProducts = byProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      backgroundColor: AppTheme.getBackground(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Selector de período ─────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceCard(isDark),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.getBorder(isDark)),
              ),
              child: Row(
                children: _periods.map((p) {
                  final isActive = p == _period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _period = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color:
                              isActive ? AppTheme.accent : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          p,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isActive
                                ? Colors.black
                                : AppTheme.getTextSecondary(isDark),
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            if (orders.isEmpty) ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded,
                          size: 72, color: AppTheme.getTextSecondary(isDark)),
                      const SizedBox(height: 16),
                      Text('Sin ventas en este período',
                          style: TextStyle(
                              color: AppTheme.getTextPrimary(isDark),
                              fontWeight: FontWeight.w600,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Los pedidos completados aparecerán aquí',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // ── KPIs ppales ──
              _SectionTitle(title: 'Resumen general', isDark: isDark),
              const SizedBox(height: 12),
              Row(
                children: [
                  _KpiCard(
                    label: 'Ingresos totales',
                    value: '\$${revenue.toStringAsFixed(2)}',
                    icon: Icons.attach_money_rounded,
                    color: AppTheme.accent,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _KpiCard(
                    label: 'Total pedidos',
                    value: '${orders.length}',
                    icon: Icons.receipt_long_rounded,
                    color: AppTheme.success,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _KpiCard(
                    label: 'Artículos vendidos',
                    value: '$totalItems',
                    icon: Icons.shopping_bag_outlined,
                    color: const Color(0xFF60A5FA),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 10),
                  _KpiCard(
                    label: 'Ticket promedio',
                    value: orders.isNotEmpty
                        ? '\$${(revenue / orders.length).toStringAsFixed(2)}'
                        : '\$0.00',
                    icon: Icons.analytics_outlined,
                    color: const Color(0xFFA78BFA),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 28),

              _SectionTitle(title: 'Desglose financiero', isDark: isDark),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceCard(isDark),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.getBorder(isDark)),
                ),
                child: Column(
                  children: [
                    _FinanceRow(
                      label: 'Subtotal productos',
                      value: '\$${subtotal.toStringAsFixed(2)}',
                      isDark: isDark,
                    ),
                    Divider(color: AppTheme.getBorder(isDark), height: 20),
                    _FinanceRow(
                      label: 'Costo de envíos',
                      value: '\$${shipping.toStringAsFixed(2)}',
                      isDark: isDark,
                    ),
                    Divider(color: AppTheme.getBorder(isDark), height: 20),
                    _FinanceRow(
                      label: 'Total ingresos',
                      value: '\$${revenue.toStringAsFixed(2)}',
                      isDark: isDark,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              if (byStatus.isNotEmpty) ...[
                _SectionTitle(title: 'Estado de pedidos', isDark: isDark),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceCard(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.getBorder(isDark)),
                  ),
                  child: Column(
                    children: byStatus.entries.map((e) {
                      final pct =
                          orders.isNotEmpty ? e.value / orders.length : 0.0;
                      final color = _statusColor(e.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: color,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(e.key,
                                        style: TextStyle(
                                            color:
                                                AppTheme.getTextPrimary(isDark),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 13)),
                                  ],
                                ),
                                Text(
                                    '${e.value} pedido${e.value != 1 ? 's' : ''}'
                                    ' (${(pct * 100).toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                        color:
                                            AppTheme.getTextSecondary(isDark),
                                        fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.getBorder(isDark),
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(color),
                                minHeight: 7,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              if (topProducts.isNotEmpty) ...[
                _SectionTitle(title: 'Productos más vendidos', isDark: isDark),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceCard(isDark),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.getBorder(isDark)),
                  ),
                  child: Column(
                    children: topProducts
                        .take(8)
                        .toList()
                        .asMap()
                        .entries
                        .map((entry) {
                      final rank = entry.key + 1;
                      final product = entry.value;
                      final maxVal = topProducts.first.value;
                      final pct = maxVal > 0 ? product.value / maxVal : 0.0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: rank == 1
                                        ? AppTheme.accent.withOpacity(0.2)
                                        : AppTheme.getBorder(isDark),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text('$rank',
                                        style: TextStyle(
                                            color: rank == 1
                                                ? AppTheme.accent
                                                : AppTheme.getTextSecondary(
                                                    isDark),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11)),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(product.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color:
                                              AppTheme.getTextPrimary(isDark),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13)),
                                ),
                                Text('\$${product.value.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: AppTheme.getTextPrimary(isDark),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppTheme.getBorder(isDark),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accent
                                        .withOpacity(0.4 + 0.6 * pct)),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              _SectionTitle(title: 'Historial de pedidos', isDark: isDark),
              const SizedBox(height: 12),
              ...orders.map((order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _OrderRow(order: order, isDark: isDark),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Entregado':
        return AppTheme.success;
      case 'Enviado':
        return const Color(0xFF60A5FA);
      case 'Procesando':
        return const Color(0xFFF59E0B);
      case 'Cancelado':
        return AppTheme.error;
      default:
        return AppTheme.accent;
    }
  }
}

// ─── Widgets aux ──────

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

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _KpiCard({
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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    color: AppTheme.getTextPrimary(isDark),
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                maxLines: 2,
                style: TextStyle(
                    color: AppTheme.getTextSecondary(isDark), fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _FinanceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;

  const _FinanceRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isTotal
                    ? AppTheme.getTextPrimary(isDark)
                    : AppTheme.getTextSecondary(isDark),
                fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
                fontSize: isTotal ? 15 : 13)),
        Text(value,
            style: TextStyle(
                color:
                    isTotal ? AppTheme.accent : AppTheme.getTextPrimary(isDark),
                fontWeight: FontWeight.w700,
                fontSize: isTotal ? 16 : 13)),
      ],
    );
  }
}

class _OrderRow extends StatelessWidget {
  final Order order;
  final bool isDark;

  const _OrderRow({required this.order, required this.isDark});

  Color _statusColor(String status) {
    switch (status) {
      case 'Entregado':
        return AppTheme.success;
      case 'Enviado':
        return const Color(0xFF60A5FA);
      case 'Procesando':
        return const Color(0xFFF59E0B);
      case 'Cancelado':
        return AppTheme.error;
      default:
        return AppTheme.accent;
    }
  }

  @override
  Widget build(BuildContext context) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.id,
                  style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(order.status,
                    style: TextStyle(
                        color: _statusColor(order.status),
                        fontWeight: FontWeight.w600,
                        fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(order.date,
              style: TextStyle(
                  color: AppTheme.getTextSecondary(isDark), fontSize: 12)),
          const SizedBox(height: 8),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    Icon(Icons.circle,
                        size: 5, color: AppTheme.getTextSecondary(isDark)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text('${item.name} × ${item.quantity}',
                          style: TextStyle(
                              color: AppTheme.getTextSecondary(isDark),
                              fontSize: 12)),
                    ),
                    Text('\$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: TextStyle(
                            color: AppTheme.getTextSecondary(isDark),
                            fontSize: 12)),
                  ],
                ),
              )),
          Divider(color: AppTheme.getBorder(isDark), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total',
                  style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
              Text('\$${order.total.toStringAsFixed(2)}',
                  style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 14)),
            ],
          ),
        ],
      ),
    );
  }
}
