import 'package:cloud_firestore/cloud_firestore.dart';

class Empleado {
  final String id;
  final String idU; // Referencia a Usuario
  final String nombre;
  final String rfc;
  final DateTime fechaNacimiento;
  final String direccion;
  final double sueldo;
  final String ocupacion;
  final List<String> telefonos; // Array de teléfonos
  final bool activo;
  final DateTime createdAt;

  Empleado({
    required this.id,
    required this.idU,
    required this.nombre,
    required this.rfc,
    required this.fechaNacimiento,
    required this.direccion,
    required this.sueldo,
    required this.ocupacion,
    required this.telefonos,
    required this.activo,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idU': idU,
      'nombre': nombre,
      'rfc': rfc,
      'fechaNacimiento': fechaNacimiento,
      'direccion': direccion,
      'sueldo': sueldo,
      'ocupacion': ocupacion,
      'telefonos': telefonos,
      'activo': activo,
      'createdAt': createdAt,
    };
  }

  factory Empleado.fromMap(Map<String, dynamic> map, String docId) {
    return Empleado(
      id: docId,
      idU: map['idU'] ?? '',
      nombre: map['nombre'] ?? '',
      rfc: map['rfc'] ?? '',
      fechaNacimiento: map['fechaNacimiento'] is Timestamp
          ? (map['fechaNacimiento'] as Timestamp).toDate()
          : DateTime.now(),
      direccion: map['direccion'] ?? '',
      sueldo: (map['sueldo'] as num?)?.toDouble() ?? 0.0,
      ocupacion: map['ocupacion'] ?? '',
      telefonos: List<String>.from(map['telefonos'] as List? ?? []),
      activo: map['activo'] ?? true,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Empleado copyWith({
    String? id,
    String? idU,
    String? nombre,
    String? rfc,
    DateTime? fechaNacimiento,
    String? direccion,
    double? sueldo,
    String? ocupacion,
    List<String>? telefonos,
    bool? activo,
    DateTime? createdAt,
  }) {
    return Empleado(
      id: id ?? this.id,
      idU: idU ?? this.idU,
      nombre: nombre ?? this.nombre,
      rfc: rfc ?? this.rfc,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      direccion: direccion ?? this.direccion,
      sueldo: sueldo ?? this.sueldo,
      ocupacion: ocupacion ?? this.ocupacion,
      telefonos: telefonos ?? this.telefonos,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
