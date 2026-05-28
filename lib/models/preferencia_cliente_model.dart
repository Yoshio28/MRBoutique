import 'package:cloud_firestore/cloud_firestore.dart';

class PreferenciaCliente {
  final String id;
  final String idC; // Referencia a Cliente (único)
  final String? direccionPred;
  final String? metodoPagoPred;
  final DateTime createdAt;

  PreferenciaCliente({
    required this.id,
    required this.idC,
    this.direccionPred,
    this.metodoPagoPred,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idC': idC,
      'direccionPred': direccionPred,
      'metodoPagoPred': metodoPagoPred,
      'createdAt': createdAt,
    };
  }

  factory PreferenciaCliente.fromMap(Map<String, dynamic> map, String docId) {
    return PreferenciaCliente(
      id: docId,
      idC: map['idC'] ?? '',
      direccionPred: map['direccionPred'],
      metodoPagoPred: map['metodoPagoPred'],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  PreferenciaCliente copyWith({
    String? id,
    String? idC,
    String? direccionPred,
    String? metodoPagoPred,
    DateTime? createdAt,
  }) {
    return PreferenciaCliente(
      id: id ?? this.id,
      idC: idC ?? this.idC,
      direccionPred: direccionPred ?? this.direccionPred,
      metodoPagoPred: metodoPagoPred ?? this.metodoPagoPred,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
