import 'package:flutter_application_1/models/product.dart';

class InvoiceItem {
  final String id;
  final String invoiceId;
  final String productId;
  final Product product;
  final int quantity;
  final double subtotal;

  InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.product,
    required this.quantity,
    required this.subtotal,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] ?? '',
      invoiceId: json['invoice_id'] ?? '',
      productId: json['product_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'product': product.toJson(),
      'quantity': quantity,
      'subtotal': subtotal,
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? productId,
    Product? product,
    int? quantity,
    double? subtotal,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
    );
  }
}
