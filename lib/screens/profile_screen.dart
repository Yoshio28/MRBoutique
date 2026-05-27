// lib/screens/profile_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import '../screens/auth/login_screen.dart';
import 'admin/admin_screens_wrapper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.getSurfaceCard(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.getBorder(isDark),
                  borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_rounded, color: AppTheme.accent),
              title: Text('Tomar foto',
                  style: TextStyle(color: AppTheme.getTextPrimary(isDark))),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(
                    source: ImageSource.camera, imageQuality: 85);
                if (photo != null && mounted)
                  await context.read<UserProvider>().updateAvatar(photo.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppTheme.accent),
              title: Text('Elegir de galería',
                  style: TextStyle(color: AppTheme.getTextPrimary(isDark))),
              onTap: () async {
                Navigator.pop(ctx);
                final XFile? photo = await _picker.pickImage(
                    source: ImageSource.gallery, imageQuality: 85);
                if (photo != null && mounted)
                  await context.read<UserProvider>().updateAvatar(photo.path);
              },
            ),
            Consumer<UserProvider>(
              builder: (_, user, __) => user.avatarPath.isNotEmpty
                  ? ListTile(
                      leading: const Icon(Icons.delete_outline_rounded,
                          color: Color(0xFFFCA5A5)),
                      title: const Text('Eliminar foto',
                          style: TextStyle(color: Color(0xFFFCA5A5))),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<UserProvider>().updateAvatar('');
                      },
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _openEditProfile() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final user = context.read<UserProvider>();
    final nameCtrl = TextEditingController(text: user.name);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceCard(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.getBorder(isDark),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Editar perfil',
                  style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              const SizedBox(height: 24),
              _EditField(
                  controller: nameCtrl,
                  label: 'Nombre de usuario',
                  icon: Icons.person_outline_rounded,
                  isDark: isDark),
              const SizedBox(height: 14),
              _EditField(
                  controller: emailCtrl,
                  label: 'Correo electrónico',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark),
              const SizedBox(height: 14),
              _EditField(
                  controller: phoneCtrl,
                  label: 'Celular',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  isDark: isDark),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<UserProvider>().updateProfile(
                          name: nameCtrl.text,
                          email: emailCtrl.text,
                          phone: phoneCtrl.text,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Perfil actualizado'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Guardar cambios',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openEditAddress() {
    final isDark = context.read<ThemeProvider>().isDarkMode;
    final user = context.read<UserProvider>();
    final addressCtrl = TextEditingController(text: user.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.getSurfaceCard(isDark),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: AppTheme.getBorder(isDark),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 20),
              Text('Editar domicilio',
                  style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w800,
                      fontSize: 20)),
              const SizedBox(height: 24),
              _EditField(
                  controller: addressCtrl,
                  label: 'Dirección completa',
                  icon: Icons.location_on_outlined,
                  isDark: isDark),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context
                        .read<UserProvider>()
                        .updateAddress(addressCtrl.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Domicilio actualizado'),
                        backgroundColor: AppTheme.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ));
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Guardar cambios',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return Scaffold(
      backgroundColor: AppTheme.getBackground(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Consumer<UserProvider>(
          builder: (_, user, __) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Header ────
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: user.isLoggedIn ? _pickImage : null,
                      child: Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceCard(isDark),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: AppTheme.accent, width: 2),
                            ),
                            child: user.avatarPath.isNotEmpty
                                ? ClipOval(
                                    child: Image.file(File(user.avatarPath),
                                        fit: BoxFit.cover))
                                : Icon(Icons.person_rounded,
                                    size: 50,
                                    color: AppTheme.getTextSecondary(isDark)),
                          ),
                          if (user.isLoggedIn)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                    color: AppTheme.accent,
                                    shape: BoxShape.circle),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.black, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(user.name,
                        style: TextStyle(
                            color: AppTheme.getTextPrimary(isDark),
                            fontWeight: FontWeight.w800,
                            fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(user.email,
                        style: TextStyle(
                            color: AppTheme.getTextSecondary(isDark),
                            fontSize: 13)),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!user.isLoggedIn) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Iniciar sesión',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 28),
              ],

              _sectionTitle('Información Personal', isDark),
              const SizedBox(height: 12),
              _ProfileOption(
                  icon: Icons.person_outline_rounded,
                  label: 'Editar perfil',
                  isDark: isDark,
                  onTap: _openEditProfile),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.location_on_outlined,
                  label: 'Editar domicilio',
                  isDark: isDark,
                  onTap: _openEditAddress),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.credit_card_outlined,
                  label: 'Métodos de pago',
                  isDark: isDark,
                  onTap: () =>
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: const Text('Próximamente disponible'),
                        backgroundColor: AppTheme.warning,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ))),
              const SizedBox(height: 28),

              _sectionTitle('Mis Compras', isDark),
              const SizedBox(height: 12),
              _ProfileOption(
                  icon: Icons.shopping_bag_outlined,
                  label: 'Mis pedidos',
                  isDark: isDark,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const OrdersScreen()))),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.favorite_outline_rounded,
                  label: 'Mi wishlist',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const WishlistScreen()))),
              const SizedBox(height: 28),

              _sectionTitle('Administración', isDark),
              const SizedBox(height: 12),
              _ProfileOption(
                  icon: Icons.people_alt_outlined,
                  label: 'Empleados',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EmployeesAdminPage()))),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.inventory_2_outlined,
                  label: 'Gestión de productos',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProductsAdminPage()))),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.warehouse_outlined,
                  label: 'Inventario',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const InventoryAdminPage()))),
              const SizedBox(height: 8),
              _ProfileOption(
                  icon: Icons.bar_chart_rounded,
                  label: 'Reportes de ventas',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SalesReportAdminPage()))),
              const SizedBox(height: 28),

              _sectionTitle('Preferencias', isDark),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceCard(isDark),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.getBorder(isDark)),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Modo oscuro',
                      style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w600)),
                  value: isDark,
                  onChanged: (v) => context.read<ThemeProvider>().setTheme(v),
                  activeColor: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 28),

              if (user.isLoggedIn)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.getSurfaceCard(isDark),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          title: Text('Cerrar sesión',
                              style: TextStyle(
                                  color: AppTheme.getTextPrimary(isDark),
                                  fontWeight: FontWeight.w700)),
                          content: Text(
                              '¿Estás seguro de que deseas cerrar sesión?',
                              style: TextStyle(
                                  color: AppTheme.getTextSecondary(isDark))),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: Text('Cancelar',
                                  style: TextStyle(
                                      color:
                                          AppTheme.getTextSecondary(isDark))),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Cerrar sesión',
                                  style: TextStyle(
                                      color: Color(0xFFFCA5A5),
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await context.read<UserProvider>().logout();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Cerrar sesión',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) => Text(
        text,
        style: TextStyle(
          color: AppTheme.getTextPrimary(isDark),
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      );
}

// ─── Widgets reu ───

class _EditField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;
  final bool isDark;

  const _EditField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.getBackground(isDark),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.getBorder(isDark)),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.accent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(color: AppTheme.getTextPrimary(isDark)),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: TextStyle(color: AppTheme.getTextSecondary(isDark)),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _ProfileOption({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.getSurfaceCard(isDark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.getBorder(isDark)),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.accent, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      color: AppTheme.getTextPrimary(isDark),
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
            ),
            Icon(Icons.arrow_forward_rounded,
                color: AppTheme.getTextSecondary(isDark), size: 18),
          ],
        ),
      ),
    );
  }
}
