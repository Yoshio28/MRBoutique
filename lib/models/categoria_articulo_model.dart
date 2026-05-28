import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriaArticulo {
  final String id;
  final String categoria;
  final DateTime createdAt;

  CategoriaArticulo({
    required this.id,
    required this.categoria,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoria': categoria,
      'createdAt': createdAt,
    };
  }

  factory CategoriaArticulo.fromMap(Map<String, dynamic> map, String docId) {
    return CategoriaArticulo(
      id: docId,
      categoria: map['categoria'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  CategoriaArticulo copyWith({
    String? id,
    String? categoria,
    DateTime? createdAt,
  }) {
    return CategoriaArticulo(
      id: id ?? this.id,
      categoria: categoria ?? this.categoria,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
