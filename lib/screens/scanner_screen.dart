// lib/screens/scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart'; // FIX: added for ThemeProvider
import '../providers/theme_provider.dart'; // FIX: added
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _scanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final code = barcodes.first.rawValue;
    if (code == null) return;

    setState(() {
      _scanned = true;
    });

    _controller.stop();

    // FIX: read isDark here so the bottom sheet also respects the theme
    final isDark = context.read<ThemeProvider>().isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceCard(isDark), // FIX: was AppTheme.surfaceCard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ResultSheet(
        code: code,
        isDark: isDark, // FIX: pass isDark down
        onScanAgain: () {
          Navigator.pop(ctx);
          setState(() => _scanned = false);
          _controller.start();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: _onDetect,
        ),
        _ScanOverlay(),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
              ),
              child: const Text(
                'Apunta al código QR del modelo',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _OverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutW = 260.0;
    const cutH = 260.0;
    final left = (size.width - cutW) / 2;
    final top = (size.height - cutH) / 2;
    final cutRect = Rect.fromLTWH(left, top, cutW, cutH);

    final paint = Paint()..color = Colors.black.withOpacity(0.6);
    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);

    final path = Path()
      ..addRect(fullRect)
      ..addRRect(RRect.fromRectAndRadius(cutRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    final cornerPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cs = 24.0;

    // Top-left
    canvas.drawLine(Offset(left, top + cs), Offset(left, top), cornerPaint);
    canvas.drawLine(Offset(left, top), Offset(left + cs, top), cornerPaint);
    // Top-right
    canvas.drawLine(
        Offset(left + cutW - cs, top), Offset(left + cutW, top), cornerPaint);
    canvas.drawLine(
        Offset(left + cutW, top), Offset(left + cutW, top + cs), cornerPaint);
    // Bottom-left
    canvas.drawLine(
        Offset(left, top + cutH - cs), Offset(left, top + cutH), cornerPaint);
    canvas.drawLine(
        Offset(left, top + cutH), Offset(left + cs, top + cutH), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(left + cutW - cs, top + cutH),
        Offset(left + cutW, top + cutH), cornerPaint);
    canvas.drawLine(Offset(left + cutW, top + cutH - cs),
        Offset(left + cutW, top + cutH), cornerPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _ResultSheet extends StatelessWidget {
  final String code;
  final bool isDark; // FIX: added
  final VoidCallback onScanAgain;

  const _ResultSheet({
    required this.code,
    required this.isDark, // FIX: added
    required this.onScanAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.getBorder(isDark), // FIX: was AppTheme.border
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded,
                color: AppTheme.success, size: 36),
          ),
          const SizedBox(height: 16),
          Text('¡QR detectado!',
              style: TextStyle(
                  color: AppTheme.getTextPrimary(isDark), // FIX: was AppTheme.textPrimary
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.getBackground(isDark), // FIX: was AppTheme.background
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.getBorder(isDark)), // FIX: was AppTheme.border
            ),
            child: Text(
              code,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 13,
                  fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Abrir modelo',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onScanAgain,
              child: Text('Escanear de nuevo',
                  style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark))), // FIX: was AppTheme.textSecondary
            ),
          ),
        ],
      ),
    );
  }
}
