// lib/models/articulo_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Articulo {
  final String id;
  final String articulo;
  final String? descripcion;
  final String? imagen;
  final double precio;
  final String idP;
  final String idCA;
  final DateTime createdAt;

  Articulo({
    required this.id,
    required this.articulo,
    this.descripcion,
    this.imagen,
    required this.precio,
    required this.idP,
    required this.idCA,
    required this.createdAt,
  });


  Map<String, dynamic> toMap() {
    return {
      'articulo':    articulo,
      'descripcion': descripcion,
      'imagen':      imagen,
      'precio':      precio,
      'idP':         idP,
      'idCA':        idCA,
      'createdAt':   Timestamp.fromDate(createdAt), 
    };
  }

  factory Articulo.fromMap(Map<String, dynamic> map, String docId) {
    return Articulo(
      id:          docId,
      articulo:    map['articulo']    as String? ?? '',
      descripcion: map['descripcion'] as String?,
      imagen:      map['imagen']      as String?,
      precio:      (map['precio']     as num?)?.toDouble() ?? 0.0,
      idP:         map['idP']         as String? ?? '',
      idCA:        map['idCA']        as String? ?? '',
      createdAt:   map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Articulo copyWith({
    String? id,
    String? articulo,
    String? descripcion,
    String? imagen,
    double? precio,
    String? idP,
    String? idCA,
    DateTime? createdAt,
  }) {
    return Articulo(
      id:          id          ?? this.id,
      articulo:    articulo    ?? this.articulo,
      descripcion: descripcion ?? this.descripcion,
      imagen:      imagen      ?? this.imagen,
      precio:      precio      ?? this.precio,
      idP:         idP         ?? this.idP,
      idCA:        idCA        ?? this.idCA,
      createdAt:   createdAt   ?? this.createdAt,
    );
  }
}