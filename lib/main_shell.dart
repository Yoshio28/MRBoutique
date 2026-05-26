// lib/main_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart'; // FIX: was missing
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/app_drawer.dart';
import 'widgets/custom_nav_bar.dart';
import 'screens/home_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _titles = [
    'Inicio',
    'Categorías',
    'Escanear QR',
    'Carrito',
    'Mi Perfil',
  ];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigate(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const CategoriesScreen();
      case 2:
        return const ScannerScreen();
      case 3:
        return const CartScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppTheme.getSurface(isDark),
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: AppTheme.getNavBarBg(isDark),
        systemNavigationBarIconBrightness: isDark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.getBackground(isDark),
      appBar: AppBar(
        backgroundColor: AppTheme.getSurface(isDark),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: AppTheme.getTextPrimary(isDark),
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      drawer: AppDrawer(
        currentIndex: _currentIndex,
        onNavigate: (index) {
          _navigate(index);
          Navigator.pop(context);
        },
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _navigate,
      ),
    );
  }
}
