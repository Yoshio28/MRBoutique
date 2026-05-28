import 'package:cloud_firestore/cloud_firestore.dart';

class Cliente {
  final String id;
  final String idU; // Referencia a Usuario
  final String nombre;
  final String? rfc;
  final String direccion;
  final String telefono;
  final DateTime fechaNacimiento;
  final String? metodoPago;
  final bool activo;
  final DateTime createdAt;

  Cliente({
    required this.id,
    required this.idU,
    required this.nombre,
    this.rfc,
    required this.direccion,
    required this.telefono,
    required this.fechaNacimiento,
    this.metodoPago,
    required this.activo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idU': idU,
      'nombre': nombre,
      'rfc': rfc,
      'direccion': direccion,
      'telefono': telefono,
      'fechaNacimiento': fechaNacimiento,
      'metodoPago': metodoPago,
      'activo': activo,
      'createdAt': createdAt,
    };
  }

  factory Cliente.fromMap(Map<String, dynamic> map, String docId) {
    return Cliente(
      id: docId,
      idU: map['idU'] ?? '',
      nombre: map['nombre'] ?? '',
      rfc: map['rfc'],
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      fechaNacimiento: map['fechaNacimiento'] is Timestamp
          ? (map['fechaNacimiento'] as Timestamp).toDate()
          : DateTime.now(),
      metodoPago: map['metodoPago'],
      activo: map['activo'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Cliente copyWith({
    String? id,
    String? idU,
    String? nombre,
    String? rfc,
    String? direccion,
    String? telefono,
    DateTime? fechaNacimiento,
    String? metodoPago,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Cliente(
      id: id ?? this.id,
      idU: idU ?? this.idU,
      nombre: nombre ?? this.nombre,
      rfc: rfc ?? this.rfc,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      metodoPago: metodoPago ?? this.metodoPago,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
