import 'package:cloud_firestore/cloud_firestore.dart';

class QR {
  final String id;
  final String url;
  final DateTime createdAt;

  QR({
    required this.id,
    required this.url,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'createdAt': createdAt,
    };
  }

  factory QR.fromMap(Map<String, dynamic> map, String docId) {
    return QR(
      id: docId,
      url: map['url'] ?? '',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  QR copyWith({
    String? id,
    String? url,
    DateTime? createdAt,
  }) {
    return QR(
      id: id ?? this.id,
      url: url ?? this.url,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
