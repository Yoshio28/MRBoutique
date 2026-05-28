// lib/screens/orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/orders_provider.dart';
import '../theme/app_theme.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark  = context.watch<ThemeProvider>().isDarkMode;
    final orders  = context.watch<OrdersProvider>().orders;

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
          'Mis Pedidos',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: orders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined,
                      size: 80, color: AppTheme.getTextSecondary(isDark)),
                  const SizedBox(height: 16),
                  Text('No tienes pedidos',
                      style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w600, fontSize: 18)),
                  const SizedBox(height: 8),
                  Text('Realiza tu primer compra',
                      style: TextStyle(
                          color: AppTheme.getTextSecondary(isDark),
                          fontSize: 14)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                children: orders.map((order) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceCard(isDark),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.getBorder(isDark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header: ID + estado ──────────────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order.id,
                                      style: TextStyle(
                                          color: AppTheme.getTextPrimary(isDark),
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14)),
                                  const SizedBox(height: 4),
                                  Text(order.date,
                                      style: TextStyle(
                                          color: AppTheme.getTextSecondary(isDark),
                                          fontSize: 12)),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _statusColor(order.status)
                                      .withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(order.status,
                                    style: TextStyle(
                                        color: _statusColor(order.status),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Divider(color: AppTheme.getBorder(isDark), height: 1),
                          const SizedBox(height: 12),

                          // ── Productos ────────────────────────────────────
                          ...order.items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    // Color del ítem
                                    Container(
                                      width: 12, height: 12,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(
                                            item.color.replaceFirst('#', '0xFF'))),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppTheme.getBorder(isDark)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(item.name,
                                          style: TextStyle(
                                              color: AppTheme.getTextPrimary(isDark),
                                              fontSize: 13)),
                                    ),
                                    Text(
                                      'x${item.quantity}  \$${(item.price * item.quantity).toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: AppTheme.getTextSecondary(isDark),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              )),

                          const SizedBox(height: 8),
                          Divider(color: AppTheme.getBorder(isDark), height: 1),
                          const SizedBox(height: 12),

                          // ── Subtotal + envío + total ─────────────────────
                          _PriceRow(
                            label: 'Subtotal',
                            value: '\$${order.subtotal.toStringAsFixed(2)}',
                            isDark: isDark,
                            isSecondary: true,
                          ),
                          const SizedBox(height: 4),
                          _PriceRow(
                            label: 'Envío',
                            value: '\$${order.shipping.toStringAsFixed(2)}',
                            isDark: isDark,
                            isSecondary: true,
                          ),
                          const SizedBox(height: 8),
                          _PriceRow(
                            label: 'Total',
                            value: '\$${order.total.toStringAsFixed(2)}',
                            isDark: isDark,
                            isAccent: true,
                          ),
                          const SizedBox(height: 12),

                          // ── Botón detalles ───────────────────────────────
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.accent),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Ver detalles',
                                  style: TextStyle(
                                      color: AppTheme.accent,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Entregado':  return AppTheme.success;
      case 'En camino':  return AppTheme.accent;
      case 'Procesando': return AppTheme.warning;
      default:           return AppTheme.getTextSecondary(true);
    }
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isSecondary;
  final bool isAccent;

  const _PriceRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isSecondary = false,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isSecondary
                    ? AppTheme.getTextSecondary(isDark)
                    : AppTheme.getTextPrimary(isDark),
                fontWeight: isAccent ? FontWeight.w700 : FontWeight.w500,
                fontSize: isAccent ? 15 : 13)),
        Text(value,
            style: TextStyle(
                color: isAccent
                    ? AppTheme.accent
                    : AppTheme.getTextSecondary(isDark),
                fontWeight: isAccent ? FontWeight.w800 : FontWeight.w500,
                fontSize: isAccent ? 15 : 13)),
      ],
    );
  }
}
