import 'package:flutter_application_1/models/invoice_item.dart';

class Invoice {
  final String id;
  final String? userId;
  final List<InvoiceItem> items;
  final double total;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Invoice({
    required this.id,
    this.userId,
    required this.items,
    required this.total,
    required this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] ?? '',
      userId: json['user_id'],
      items:
          (json['invoice_items'] as List<dynamic>?)
              ?.map((item) => InvoiceItem.fromJson(item))
              .toList() ??
          [],
      total: (json['total'] ?? 0.0).toDouble(),
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'invoice_items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Invoice copyWith({
    String? id,
    String? userId,
    List<InvoiceItem>? items,
    double? total,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
