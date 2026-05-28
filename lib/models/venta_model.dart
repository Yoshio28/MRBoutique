import 'package:cloud_firestore/cloud_firestore.dart';

class Venta {
  final String id;
  final String idPed; // Referencia a Pedido
  final DateTime createdAt;

  Venta({
    required this.id,
    required this.idPed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idPed': idPed,
      'createdAt': createdAt,
    };
  }

  factory Venta.fromMap(Map<String, dynamic> map, String docId) {
    return Venta(
      id: docId,
      idPed: map['idPed'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Venta copyWith({
    String? id,
    String? idPed,
    DateTime? createdAt,
  }) {
    return Venta(
      id: id ?? this.id,
      idPed: idPed ?? this.idPed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
