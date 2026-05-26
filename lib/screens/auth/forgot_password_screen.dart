// lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading  = false;
  bool _sent     = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = 'Ingresa un correo electrónico válido.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    await Future.delayed(const Duration(milliseconds: 1200)); // simula red
    setState(() { _loading = false; _sent = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: AppTheme.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Recuperar contraseña',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: _sent ? _SuccessView(email: _emailCtrl.text.trim(),
                onBack: () => Navigator.pop(context))
              : _FormView(
                  emailCtrl: _emailCtrl,
                  loading: _loading,
                  error: _error,
                  onSend: _send,
                ),
        ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool loading;
  final String? error;
  final VoidCallback onSend;

  const _FormView({
    required this.emailCtrl,
    required this.loading,
    required this.error,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 36),

        // Ícono
        Center(
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.accent.withOpacity(0.25)),
            ),
            child: const Icon(Icons.lock_reset_rounded,
                color: AppTheme.accent, size: 36),
          ),
        ),
        const SizedBox(height: 28),

        const Text('¿Olvidaste tu contraseña?',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        const Text(
          'Ingresa tu correo electrónico y te enviaremos un enlace para restablecer tu contraseña.',
          style: TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.5),
        ),
        const SizedBox(height: 32),

        const Text('Correo electrónico',
            style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: TextField(
            controller: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            style:
                const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email_outlined,
                  color: AppTheme.accent, size: 20),
              hintText: 'tu@correo.com',
              hintStyle:
                  TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),

        if (error != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF7F1D1D).withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: const Color(0xFF7F1D1D).withOpacity(0.4)),
            ),
            child: Text(error!,
                style: const TextStyle(
                    color: Color(0xFFFCA5A5), fontSize: 13)),
          ),
        ],
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: loading ? null : onSend,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: loading
                      ? [AppTheme.accent.withOpacity(0.5),
                         AppTheme.accent.withOpacity(0.3)]
                      : [AppTheme.accent, const Color(0xFF0099CC)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.accent.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text('Enviar enlace',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String email;
  final VoidCallback onBack;
  const _SuccessView({required this.email, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.1),
            shape: BoxShape.circle,
            border:
                Border.all(color: AppTheme.success.withOpacity(0.3), width: 2),
          ),
          child: const Icon(Icons.mark_email_read_outlined,
              color: AppTheme.success, size: 44),
        ),
        const SizedBox(height: 28),
        const Text('¡Correo enviado!',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        Text(
          'Revisa tu bandeja de entrada en\n$email\npara restablecer tu contraseña.',
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
        ),
        const SizedBox(height: 36),
        SizedBox(
          width: double.infinity,
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, Color(0xFF0099CC)],
                ),
              ),
              child: const Center(
                child: Text('Volver al inicio de sesión',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
