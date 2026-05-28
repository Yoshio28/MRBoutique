// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_boutique/providers/user_provider.dart';
import 'package:mr_boutique/providers/theme_provider.dart';
import 'package:mr_boutique/theme/app_theme.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Por favor completa todos los campos.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _error = 'Ingresa un correo válido.');
      return;
    }
    if (password.length < 6) {
      setState(
          () => _error = 'La contraseña debe tener al menos 6 caracteres.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final name = email.split('@').first;

    await context.read<UserProvider>().login(name: name, email: email);

    setState(() => _loading = false);

    if (mounted) Navigator.pop(context);
  }

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
          'Iniciar sesión',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo / ilustración
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded,
                      color: AppTheme.accent, size: 48),
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Bienvenido',
                style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.w800,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Inicia sesión para continuar comprando.',
                style: TextStyle(
                  color: AppTheme.getTextSecondary(isDark),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),

              _label('Correo electrónico', isDark),
              const SizedBox(height: 8),
              _InputField(
                controller: _emailCtrl,
                hint: 'tu@correo.com',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                isDark: isDark,
              ),
              const SizedBox(height: 16),

              _label('Contraseña', isDark),
              const SizedBox(height: 8),
              _InputField(
                controller: _passwordCtrl,
                hint: '••••••••',
                icon: Icons.lock_outline_rounded,
                isDark: isDark,
                obscure: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppTheme.getTextSecondary(isDark),
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 10),

              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const ForgotPasswordScreen()),
                  ),
                  child: const Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: AppTheme.error, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(
                              color: AppTheme.error, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // login btn
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: AppTheme.accent.withOpacity(0.5),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.black, strokeWidth: 2),
                        )
                      : const Text(
                          'Iniciar sesión',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          color: AppTheme.getTextPrimary(isDark),
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isDark;
  final bool obscure;
  final Widget? suffixIcon;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.isDark,
    this.obscure = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscure,
              style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(color: AppTheme.getTextSecondary(isDark)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (suffixIcon != null) suffixIcon!,
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
