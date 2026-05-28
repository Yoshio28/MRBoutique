// lib/widgets/custom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        color: AppTheme.getNavBarBg(isDark),
        border: Border(
          top: BorderSide(color: AppTheme.getBorder(isDark), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        height: 70,
        child: Row(
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'Inicio',
              index: 0,
              currentIndex: currentIndex,
              onTap: onTap,
              isDark: isDark,
            ),
            _NavItem(
              icon: Icons.category_outlined,
              activeIcon: Icons.category_rounded,
              label: 'Categorías',
              index: 1,
              currentIndex: currentIndex,
              onTap: onTap,
              isDark: isDark,
            ),
            _QRCenterButton(
              isActive: currentIndex == 2,
              onTap: () => onTap(2),
              isDark: isDark,
            ),
            _NavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag_rounded,
              label: 'Carrito',
              index: 3,
              currentIndex: currentIndex,
              onTap: onTap,
              isDark: isDark,
              badge: true,
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Perfil',
              index: 4,
              currentIndex: currentIndex,
              onTap: onTap,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int currentIndex;
  final Function(int) onTap;
  final bool isDark;
  final bool badge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
    this.badge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppTheme.accent.withOpacity(0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isActive ? activeIcon : icon,
                      color: isActive
                          ? AppTheme.accent
                          : AppTheme.getTextSecondary(isDark),
                      size: 24,
                    ),
                  ),
                  if (badge)
                    Consumer<CartProvider>(
                      builder: (context, cart, _) {
                        return cart.itemCount > 0
                            ? Positioned(
                                top: 0,
                                right: 0,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.error,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${cart.itemCount}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink();
                      },
                    ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: isActive
                      ? AppTheme.accent
                      : AppTheme.getTextSecondary(isDark),
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QRCenterButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _QRCenterButton({
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
              offset: const Offset(0, -8),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withOpacity(0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.black,
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Escanear',
              style: TextStyle(
                color: AppTheme.getTextSecondary(isDark),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
