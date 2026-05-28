import 'package:cloud_firestore/cloud_firestore.dart';

class Inventario {
  final String id;
  final String descripcion;
  final String idA; // Referencia a Articulo
  final String idP; // Referencia a Proveedor
  final int stock;
  final DateTime createdAt;

  Inventario({
    required this.id,
    required this.descripcion,
    required this.idA,
    required this.idP,
    required this.stock,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'idA': idA,
      'idP': idP,
      'stock': stock,
      'createdAt': createdAt,
    };
  }

  factory Inventario.fromMap(Map<String, dynamic> map, String docId) {
    return Inventario(
      id: docId,
      descripcion: map['descripcion'] ?? '',
      idA: map['idA'] ?? '',
      idP: map['idP'] ?? '',
      stock: map['stock'] ?? 0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Inventario copyWith({
    String? id,
    String? descripcion,
    String? idA,
    String? idP,
    int? stock,
    DateTime? createdAt,
  }) {
    return Inventario(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      idA: idA ?? this.idA,
      idP: idP ?? this.idP,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
