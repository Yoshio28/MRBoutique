import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final String descripcion;
  final String idC; // Referencia a Cliente
  final String idA; // Referencia a Articulo
  final int cantidad;
  final double precio;
  final String status; // 'Pagado', 'Pendiente', 'En Proceso', 'Cancelado'
  final DateTime createdAt;

  Pedido({
    required this.id,
    required this.descripcion,
    required this.idC,
    required this.idA,
    required this.cantidad,
    required this.precio,
    required this.status,
    required this.createdAt,
  });

  // Calcular total
  double get total => cantidad * precio;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'descripcion': descripcion,
      'idC': idC,
      'idA': idA,
      'cantidad': cantidad,
      'precio': precio,
      'total': total,
      'status': status,
      'createdAt': createdAt,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map, String docId) {
    return Pedido(
      id: docId,
      descripcion: map['descripcion'] ?? '',
      idC: map['idC'] ?? '',
      idA: map['idA'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precio: (map['precio'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'En Proceso',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Pedido copyWith({
    String? id,
    String? descripcion,
    String? idC,
    String? idA,
    int? cantidad,
    double? precio,
    String? status,
    DateTime? createdAt,
  }) {
    return Pedido(
      id: id ?? this.id,
      descripcion: descripcion ?? this.descripcion,
      idC: idC ?? this.idC,
      idA: idA ?? this.idA,
      cantidad: cantidad ?? this.cantidad,
      precio: precio ?? this.precio,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
