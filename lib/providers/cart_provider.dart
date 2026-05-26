// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';

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
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice =>
      _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

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
  }

  void removeItem(String id, String color) {
    _items.removeWhere((item) => item.id == id && item.color == color);
    notifyListeners();
  }

  void updateQuantity(String id, String color, int quantity) {
    final item = _items.firstWhere(
      (i) => i.id == id && i.color == color,
      orElse: () => CartItem(
        id: '',
        name: '',
        price: 0,
        image: '',
        color: '',
      ),
    );
    if (item.id.isNotEmpty) {
      item.quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}