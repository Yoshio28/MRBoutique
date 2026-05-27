// lib/providers/orders_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'cart_provider.dart';

class OrderItem {
  final String name;
  final String color;
  final double price;
  final int quantity;

  OrderItem({
    required this.name,
    required this.color,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'color': color,
        'price': price,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> j) => OrderItem(
        name: j['name'] as String,
        color: j['color'] as String,
        price: (j['price'] as num).toDouble(),
        quantity: j['quantity'] as int,
      );
}

class Order {
  final String id;
  final String date;
  final double subtotal;
  final double shipping;
  final double total;
  String status;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.date,
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.status,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date,
        'subtotal': subtotal,
        'shipping': shipping,
        'total': total,
        'status': status,
        'items': items.map((e) => e.toJson()).toList(),
      };

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        date: j['date'] as String,
        subtotal: (j['subtotal'] as num).toDouble(),
        shipping: (j['shipping'] as num).toDouble(),
        total: (j['total'] as num).toDouble(),
        status: j['status'] as String,
        items: (j['items'] as List)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class OrdersProvider extends ChangeNotifier {
  static const _kKey = 'orders_list';
  static const double shippingCost = 50.0;

  final List<Order> _orders = [];

  List<Order> get orders => List.unmodifiable(_orders);

  OrdersProvider() {
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kKey);
      if (raw != null) {
        final List decoded = jsonDecode(raw) as List;
        _orders.addAll(
          decoded.map((e) => Order.fromJson(e as Map<String, dynamic>)),
        );
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kKey, jsonEncode(_orders.map((e) => e.toJson()).toList()));
  }

  /// Crea un pedido a partir de los ítems del carrito y lo persiste.
  Future<void> placeOrder(List<CartItem> cartItems) async {
    final subtotal =
        cartItems.fold<double>(0, (s, i) => s + i.price * i.quantity);
    final total = subtotal + shippingCost;

    final now = DateTime.now();
    final months = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];
    final dateStr =
        '${now.day} de ${months[now.month - 1]}, ${now.year}';

    final order = Order(
      id: '#ORD-${now.millisecondsSinceEpoch.toString().substring(7)}',
      date: dateStr,
      subtotal: subtotal,
      shipping: shippingCost,
      total: total,
      status: 'Procesando',
      items: cartItems
          .map((i) => OrderItem(
                name: i.name,
                color: i.color,
                price: i.price,
                quantity: i.quantity,
              ))
          .toList(),
    );

    _orders.insert(0, order);
    notifyListeners();
    await _save();
  }
}
