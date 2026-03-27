import 'package:flutter/material.dart';
@immutable
class MaterialOption {
  const MaterialOption({
    required this.id,
    required this.name,
    required this.quantity,
    required this.avail,
    required this.price,
  });

  final String id;
  final String name;
  final int quantity;
  final bool avail;
  final double price;

  factory MaterialOption.fromMap(Map<String, dynamic> data, String documentId) {
    return MaterialOption(
      id: documentId,
      name: data['name'] ?? '',
      quantity: data['quantity'] ?? 0,
      avail: data['avail'] ?? false,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'quantity': quantity, 'avail': avail, 'price': price};
  }

  MaterialOption copyWith({
    String? name,
    int? quantity,
    bool? avail,
    double? price,
  }) {
    return MaterialOption(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      avail: avail ?? this.avail,
      price: price ?? this.price,
    );
  }
}