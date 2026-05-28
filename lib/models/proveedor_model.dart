import 'package:cloud_firestore/cloud_firestore.dart';

class Proveedor {
  final String id;
  final String proveedor;
  final List<String> telefonos; // Array de teléfonos
  final bool activo;
  final DateTime createdAt;

  Proveedor({
    required this.id,
    required this.proveedor,
    required this.telefonos,
    required this.activo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'proveedor': proveedor,
      'telefonos': telefonos,
      'activo': activo,
      'createdAt': createdAt,
    };
  }

  factory Proveedor.fromMap(Map<String, dynamic> map, String docId) {
    return Proveedor(
      id: docId,
      proveedor: map['proveedor'] ?? '',
      telefonos: List<String>.from(map['telefonos'] as List? ?? []),
      activo: map['activo'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Proveedor copyWith({
    String? id,
    String? proveedor,
    List<String>? telefonos,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Proveedor(
      id: id ?? this.id,
      proveedor: proveedor ?? this.proveedor,
      telefonos: telefonos ?? this.telefonos,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
