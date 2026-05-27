// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/orders_provider.dart';
import 'screens/employees_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/products_admin_screen.dart';
import 'theme/app_theme.dart';
import 'main_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => EmployeesProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => ProductsAdminProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MRBoutique',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
