// lib/screens/categories_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // FIX: was missing
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'category_products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    final categories = [
      {
        'name': 'Blusas',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'Camisas',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFF10B981),
      },
      {
        'name': 'Conjuntos',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFF7C3AED),
      },
      {
        'name': 'Faldas',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFFEC4899),
      },
      {
        'name': 'Pantalones',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFFF59E0B),
      },
      {
        'name': 'Vestidos',
        'icon': Icons.checkroom_rounded,
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryProductsScreen(
                        categoryName: category['name'] as String,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.getSurfaceCard(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.getBorder(isDark),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: (category['color'] as Color)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category['icon'] as IconData,
                          color: category['color'] as Color,
                          size: 40,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        category['name'] as String,
                        style: TextStyle(
                          color: AppTheme.getTextPrimary(isDark),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
