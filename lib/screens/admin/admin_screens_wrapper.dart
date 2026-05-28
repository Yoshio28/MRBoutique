// lib/screens/admin/admin_screens_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../theme/app_theme.dart';
import '../employees_screen.dart';
import '../inventory_screen.dart';
import '../products_admin_screen.dart';
import '../sales_report_screen.dart';

// ─── Empleados ───

class EmployeesAdminPage extends StatelessWidget {
  const EmployeesAdminPage({super.key});

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
          'Empleados',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: const EmployeesScreen(),
    );
  }
}

// ─── Productos ─────

class ProductsAdminPage extends StatelessWidget {
  const ProductsAdminPage({super.key});

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
          'Gestión de productos',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: const ProductsAdminScreen(),
    );
  }
}

// ─── Inventario ──────

class InventoryAdminPage extends StatelessWidget {
  const InventoryAdminPage({super.key});

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
          'Inventario',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: const InventoryScreen(),
    );
  }
}

// ─── Reportes de ventas ──

class SalesReportAdminPage extends StatelessWidget {
  const SalesReportAdminPage({super.key});

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
          'Reportes de ventas',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: const SalesReportScreen(),
    );
  }
}
