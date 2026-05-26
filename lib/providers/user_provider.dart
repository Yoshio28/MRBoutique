// lib/providers/user_provider.dart
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Usuario';
  String _email = 'usuario@example.com';
  String _phone = '+1 234 567 8900';
  String _address = '';
  String _avatarPath = '';

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get address => _address;
  String get avatarPath => _avatarPath;

  Future<void> login({
    required String name,
    required String email,
    String phone = '',
  }) async {
    _name = name;
    _email = email;
    if (phone.isNotEmpty) _phone = phone;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _name = name;
    _email = email;
    _phone = phone;
    notifyListeners();
  }

  Future<void> updateAddress(String address) async {
    _address = address;
    notifyListeners();
  }

  Future<void> updateAvatar(String path) async {
    _avatarPath = path;
    notifyListeners();
  }

  Future<void> logout() async {
    _name = 'Usuario';
    _email = 'usuario@example.com';
    _phone = '+1 234 567 8900';
    _address = '';
    _avatarPath = '';
    notifyListeners();
  }
}
