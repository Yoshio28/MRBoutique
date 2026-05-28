// lib/providers/wishlist_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final List<String> colors;

  WishlistItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.colors,
  });

  // ✅ Serialización para persistencia
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'colors': colors,
      };

  factory WishlistItem.fromJson(Map<String, dynamic> json) => WishlistItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String,
        colors: List<String>.from(json['colors'] as List),
      );
}

class WishlistProvider extends ChangeNotifier {
  static const _kKey = 'wishlist_items';

  final List<WishlistItem> _items = [];

  List<WishlistItem> get items => _items;
  int get itemCount => _items.length;
  bool isInWishlist(String id) => _items.any((item) => item.id == id);

  WishlistProvider() {
    _load();
  }

  // ─── Persistencia ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _items.addAll(
          decoded.map((e) => WishlistItem.fromJson(e as Map<String, dynamic>)),
        );
        notifyListeners();
      }
    } catch (_) {
      // Datos corruptos → lista vacía
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  // ─── Operaciones ────────────────────────────────────────────────────────────

  void addItem(WishlistItem item) {
    if (!isInWishlist(item.id)) {
      _items.add(item);
      notifyListeners();
      _save();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    _save();
  }

  void toggleItem(WishlistItem item) {
    if (isInWishlist(item.id)) {
      removeItem(item.id);
    } else {
      addItem(item);
    }
  }
}
