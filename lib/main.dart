// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mr_boutique/screens/employees_screen.dart';
import 'package:mr_boutique/screens/inventory_screen.dart';
import 'package:mr_boutique/screens/products_admin_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/orders_provider.dart';
import 'theme/app_theme.dart';
import 'main_shell.dart';
import 'screens/auth/login_screen.dart';
import 'services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
        ChangeNotifierProvider(create: (_) => ProductsAdminProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'MRBoutique',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.getLightTheme(),
            darkTheme: AppTheme.getDarkTheme(),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const AuthGate(),
          );
        },
      ),
    );
  }
}


class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final firebaseUser = snapshot.data;

        if (firebaseUser == null) {
          return const LoginScreen();
        }

        return _HydratedShell(
          uid:   firebaseUser.uid,
          email: firebaseUser.email ?? '',
        );
      },
    );
  }
}

class _HydratedShell extends StatefulWidget {
  final String uid;
  final String email;
  const _HydratedShell({required this.uid, required this.email});

  @override
  State<_HydratedShell> createState() => _HydratedShellState();
}

class _HydratedShellState extends State<_HydratedShell> {
  late final Future<void> _hydration;

  @override
  void initState() {
    super.initState();
    _hydration = _hydrate();
  }

  Future<void> _hydrate() async {
    final userProvider = context.read<UserProvider>();

    // Si SharedPreferences ya tiene sesión, no hace falta ir a Firestore
    if (userProvider.isLoggedIn) return;

    try {
      final db      = DatabaseService();
      final cliente = await db.obtenerClientePorUid(widget.uid);

      if (!mounted) return;

      if (cliente != null) {
        // Datos completos desde Firestore
        await userProvider.login(
          name:  cliente.nombre,
          email: widget.email,
          phone: cliente.telefono,
        );
      } else {
        // No hay documento en Firestore todavía — igual dejamos entrar
        await userProvider.login(
          name:  widget.email.split('@').first,
          email: widget.email,
          phone: '',
        );
      }
    } catch (e) {
      print('_hydrate error → $e');
      // Nunca bloquear el acceso por un error de Firestore
      if (mounted) {
        await context.read<UserProvider>().login(
          name:  widget.email.split('@').first,
          email: widget.email,
          phone: '',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _hydration,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return const MainShell();
      },
    );
  }
}