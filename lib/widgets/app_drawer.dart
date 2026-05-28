// lib/widgets/app_drawer.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // FIX: was missing
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavigate;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Drawer(
      width: 285,
      backgroundColor: AppTheme.getSurface(isDark),
      child: Column(
        children: [
          _DrawerHeader(isDark: isDark),
          const SizedBox(height: 8),

          _DrawerItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            isActive: currentIndex == 0,
            onTap: () => onNavigate(0),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.category_rounded,
            label: 'Categorías',
            isActive: currentIndex == 1,
            onTap: () => onNavigate(1),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.qr_code_scanner_rounded,
            label: 'Escanear QR',
            isActive: currentIndex == 2,
            onTap: () => onNavigate(2),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.shopping_bag_rounded,
            label: 'Carrito',
            isActive: currentIndex == 3,
            onTap: () => onNavigate(3),
            isDark: isDark,
          ),
          _DrawerItem(
            icon: Icons.person_rounded,
            label: 'Perfil',
            isActive: currentIndex == 4,
            onTap: () => onNavigate(4),
            isDark: isDark,
          ),

          const Spacer(),

          Consumer<UserProvider>(
            builder: (_, user, __) => user.isLoggedIn
                ? Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.getSurfaceCard(isDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            title: Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: AppTheme.getTextPrimary(isDark),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            content: Text(
                              '¿Estás seguro de que deseas cerrar sesión?',
                              style: TextStyle(
                                color: AppTheme.getTextSecondary(isDark),
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                    color: AppTheme.getTextSecondary(isDark),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text(
                                  'Cerrar sesión',
                                  style: TextStyle(
                                    color: Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await user.logout();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.getSurfaceCard(isDark),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.getBorder(isDark)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              color: Color(0xFFFCA5A5),
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Cerrar sesión',
                              style: TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final bool isDark;

  const _DrawerHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, user, __) => Container(
        padding: const EdgeInsets.fromLTRB(16, 28, 16, 20),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          border: Border(bottom: BorderSide(color: AppTheme.getBorder(isDark))),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.getBackground(isDark),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accent, width: 2),
              ),
              child: user.avatarPath.isNotEmpty
                  ? ClipOval(
                      child: Image.file(
                        File(user.avatarPath),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.person_rounded,
                      color: AppTheme.getTextSecondary(isDark),
                      size: 28,
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.getTextSecondary(isDark),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accent.withOpacity(0.15)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppTheme.accent : AppTheme.getTextSecondary(isDark),
          size: 22,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? AppTheme.accent : AppTheme.getTextPrimary(isDark),
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            fontSize: 14,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
