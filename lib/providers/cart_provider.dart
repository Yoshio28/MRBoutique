// lib/providers/cart_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String id;
  final String name;
  final double price;
  final String image;
  final String color;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.color,
    this.quantity = 1,
  });

  // ✅ Serialización para persistencia
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'image': image,
        'color': color,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String,
        color: json['color'] as String,
        quantity: json['quantity'] as int,
      );
}

class CartProvider extends ChangeNotifier {
  static const _kKey = 'cart_items';

  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get itemCount => _items.length;
  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  CartProvider() {
    _load();
  }

  // ─── Persistencia ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _items.addAll(decoded.map((e) => CartItem.fromJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {
      // Si los datos están corruptos, empezamos con carrito vacío
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode(_items.map((e) => e.toJson()).toList()));
  }

  // ─── Operaciones ────────────────────────────────────────────────────────────

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere(
      (i) => i.id == item.id && i.color == item.color,
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
    _save();
  }

  void removeItem(String id, String color) {
    _items.removeWhere((item) => item.id == id && item.color == color);
    notifyListeners();
    _save();
  }

  void updateQuantity(String id, String color, int quantity) {
    final index = _items.indexWhere((i) => i.id == id && i.color == color);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
      _save();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _save();
  }
}
