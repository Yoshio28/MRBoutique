import 'package:cloud_firestore/cloud_firestore.dart';

class Carrito {
  final String id;
  final String idC; // Referencia a Cliente
  final String idA; // Referencia a Articulo
  final int cantidad;
  final DateTime createdAt;

  Carrito({
    required this.id,
    required this.idC,
    required this.idA,
    required this.cantidad,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idC': idC,
      'idA': idA,
      'cantidad': cantidad,
      'createdAt': createdAt,
    };
  }

  factory Carrito.fromMap(Map<String, dynamic> map, String docId) {
    return Carrito(
      id: docId,
      idC: map['idC'] ?? '',
      idA: map['idA'] ?? '',
      cantidad: map['cantidad'] ?? 1,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Carrito copyWith({
    String? id,
    String? idC,
    String? idA,
    int? cantidad,
    DateTime? createdAt,
  }) {
    return Carrito(
      id: id ?? this.id,
      idC: idC ?? this.idC,
      idA: idA ?? this.idA,
      cantidad: cantidad ?? this.cantidad,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
