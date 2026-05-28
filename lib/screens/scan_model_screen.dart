// lib/screens/scan_model_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // FIX: added for ThemeProvider
import '../providers/theme_provider.dart'; // FIX: added
import '../theme/app_theme.dart';

class ScanModelScreen extends StatelessWidget {
  const ScanModelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: was using only hard-coded dark static constants; now reads isDark so
    //      colours update correctly when the user switches to light mode.
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: [
                  AppTheme.success.withOpacity(0.09),
                  AppTheme.accent.withOpacity(0.09),
                ],
              ),
              border: Border.all(color: AppTheme.getBorder(isDark)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.document_scanner_rounded,
                    color: AppTheme.success, size: 28),
                const SizedBox(height: 12),
                Text('Escanear Modelo',
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark),
                        fontWeight: FontWeight.w800,
                        fontSize: 22)),
                const SizedBox(height: 6),
                Text(
                    'Usa la cámara para identificar y cargar modelos 3D desde el entorno físico.',
                    style: TextStyle(
                        color: AppTheme.getTextSecondary(isDark),
                        fontSize: 13,
                        height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Text('Métodos de escaneo',
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(height: 14),
          _ScanMethod(
            icon: Icons.qr_code_scanner_rounded,
            title: 'Código QR',
            subtitle: 'Escanea un código QR para cargar el modelo asociado',
            color: AppTheme.accent,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _ScanMethod(
            icon: Icons.camera_alt_rounded,
            title: 'Reconocimiento visual',
            subtitle: 'Identifica el modelo usando inteligencia artificial',
            color: const Color(0xFF7C3AED),
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _ScanMethod(
            icon: Icons.nfc_rounded,
            title: 'NFC / RFID',
            subtitle: 'Acerca el dispositivo a la etiqueta del modelo',
            color: const Color(0xFF10B981),
            isDark: isDark,
          ),
          const SizedBox(height: 28),
          Text('Historial de sesión',
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark),
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.getSurfaceCard(isDark),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.getBorder(isDark)),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.history_rounded,
                      color: AppTheme.getTextSecondary(isDark), size: 40),
                  const SizedBox(height: 10),
                  Text('Sin escaneos en esta sesión',
                      style: TextStyle(
                          color: AppTheme.getTextSecondary(isDark),
                          fontSize: 13)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanMethod extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark; // FIX: added so cards respect the active theme

  const _ScanMethod({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceCard(isDark), // FIX: was AppTheme.surfaceCard
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.getBorder(isDark)), // FIX: was AppTheme.border
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        color: AppTheme.getTextPrimary(isDark), // FIX: was AppTheme.textPrimary
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style: TextStyle(
                        color: AppTheme.getTextSecondary(isDark), // FIX: was AppTheme.textSecondary
                        fontSize: 12,
                        height: 1.4)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded,
              color: color.withOpacity(0.7), size: 14),
        ],
      ),
    );
  }
}
