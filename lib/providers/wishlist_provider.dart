// lib/providers/wishlist_provider.dart
import 'package:flutter/material.dart';

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
}

class WishlistProvider extends ChangeNotifier {
  final List<WishlistItem> _items = [];

  List<WishlistItem> get items => _items;

  int get itemCount => _items.length;

  bool isInWishlist(String id) => _items.any((item) => item.id == id);

  void addItem(WishlistItem item) {
    if (!isInWishlist(item.id)) {
      _items.add(item);
      notifyListeners();
    }
  }

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleItem(WishlistItem item) {
    if (isInWishlist(item.id)) {
      removeItem(item.id);
    } else {
      addItem(item);
    }
  }
}