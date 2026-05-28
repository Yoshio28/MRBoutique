import 'package:cloud_firestore/cloud_firestore.dart';

class Usuario {
  final String id;
  final String correo;
  final String password;
  final DateTime createdAt;

  Usuario({
    required this.id,
    required this.correo,
    required this.password,
    required this.createdAt,
  });

  // Convertir a Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'correo': correo,
      'password': password,
      'createdAt': createdAt,
    };
  }

  // Crear desde Map de Firestore
  factory Usuario.fromMap(Map<String, dynamic> map, String docId) {
    return Usuario(
      id: docId,
      correo: map['correo'] ?? '',
      password: map['password'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  // Crear copia con cambios
  Usuario copyWith({
    String? id,
    String? correo,
    String? password,
    DateTime? createdAt,
  }) {
    return Usuario(
      id: id ?? this.id,
      correo: correo ?? this.correo,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
