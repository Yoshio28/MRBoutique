// lib/screens/forgot_password_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mr_boutique/providers/theme_provider.dart';
import 'package:mr_boutique/theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      setState(() => _error = 'Por favor ingresa tu correo electrónico.');
      return;
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      setState(() => _error = 'Ingresa un correo válido.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // Simulación de envío (2 s)
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
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
          'Recuperar contraseña',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 32),
          child: _sent
              ? _SuccessView(isDark: isDark)
              : _FormView(
                  emailCtrl: _emailCtrl,
                  error: _error,
                  loading: _loading,
                  isDark: isDark,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

// ─── Vista del formulario ────────────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final String? error;
  final bool loading;
  final bool isDark;
  final VoidCallback onSubmit;

  const _FormView({
    required this.emailCtrl,
    required this.error,
    required this.loading,
    required this.isDark,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppTheme.accent, size: 46),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Ingresa tu correo y te enviaremos un enlace para restablecerla.',
          style: TextStyle(
            color: AppTheme.getTextSecondary(isDark),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Correo electrónico',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceCard(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.getBorder(isDark)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              const Icon(Icons.email_outlined,
                  color: AppTheme.accent, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
                  decoration: InputDecoration(
                    hintText: 'tu@correo.com',
                    hintStyle:
                        TextStyle(color: AppTheme.getTextSecondary(isDark)),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 14),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (error != null) ...[
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
                  child: Text(error!,
                      style:
                          const TextStyle(color: AppTheme.error, fontSize: 13)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: loading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              disabledBackgroundColor: AppTheme.accent.withOpacity(0.5),
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.black, strokeWidth: 2))
                : const Text(
                    'Enviar enlace',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
          ),
        ),
      ],
    );
  }
}

// ─── Vista de éxito ──────────────────────────────────────────────────────────
class _SuccessView extends StatelessWidget {
  final bool isDark;
  const _SuccessView({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mark_email_read_rounded,
                color: AppTheme.success, size: 46),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '¡Correo enviado!',
          style: TextStyle(
            color: AppTheme.getTextPrimary(isDark),
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Revisa tu bandeja de entrada y sigue las instrucciones para restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppTheme.getTextSecondary(isDark),
            fontSize: 14,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
