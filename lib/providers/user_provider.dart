// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  static const _kName    = 'user_name';
  static const _kEmail   = 'user_email';
  static const _kPhone   = 'user_phone';
  static const _kAddress = 'user_address';
  static const _kAvatar  = 'user_avatar';

  String _name      = 'Usuario';
  String _email     = 'usuario@example.com';
  String _phone     = '+1 234 567 8900';
  String _address   = '';
  String _avatarPath = '';

  String get name       => _name;
  String get email      => _email;
  String get phone      => _phone;
  String get address    => _address;
  String get avatarPath => _avatarPath;

  UserProvider() {
    _load();
  }

  // ─── Persistencia ───────────────────────────────────────────────────────────

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _name       = prefs.getString(_kName)    ?? _name;
    _email      = prefs.getString(_kEmail)   ?? _email;
    _phone      = prefs.getString(_kPhone)   ?? _phone;
    _address    = prefs.getString(_kAddress) ?? _address;
    _avatarPath = prefs.getString(_kAvatar)  ?? _avatarPath;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_kName,    _name),
      prefs.setString(_kEmail,   _email),
      prefs.setString(_kPhone,   _phone),
      prefs.setString(_kAddress, _address),
      prefs.setString(_kAvatar,  _avatarPath),
    ]);
  }

  // ─── Operaciones ────────────────────────────────────────────────────────────

  Future<void> login({
    required String name,
    required String email,
    String phone = '',
  }) async {
    _name  = name;
    _email = email;
    if (phone.isNotEmpty) _phone = phone;
    notifyListeners();
    await _save();
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async {
    _name  = name;
    _email = email;
    _phone = phone;
    notifyListeners();
    await _save();
  }

  Future<void> updateAddress(String address) async {
    _address = address;
    notifyListeners();
    await _save();
  }

  Future<void> updateAvatar(String path) async {
    _avatarPath = path;
    notifyListeners();
    await _save();
  }

  Future<void> logout() async {
    _name       = 'Usuario';
    _email      = 'usuario@example.com';
    _phone      = '+1 234 567 8900';
    _address    = '';
    _avatarPath = '';
    notifyListeners();
    await _save();
  }
}
