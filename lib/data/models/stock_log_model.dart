import 'package:flutter/material.dart';

class StockLog {
  final int transactionId;
  final int productId;
  final int initStock;
  final StockLogChangeType changeType;
  int quantity;
  final DateTime createdAt;

  StockLog({
    required this.transactionId,
    required this.productId,
    required this.initStock,
    required this.changeType,
    required this.quantity,
    required this.createdAt,
  });

  static StockLog fromJSON(Map<String, dynamic> json) {
    return StockLog(
      transactionId: json['transaction_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      initStock: json['init_stock'] ?? 0,
      changeType: getChangeTypeFromString(json['change_type']),
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? '1111-11-11'),
    );
  }

  static StockLogChangeType getChangeTypeFromString(String type) {
    return {
          'in': StockLogChangeType.in_,
          'out': StockLogChangeType.out,
        }[type] ??
        StockLogChangeType.in_;
  }

  Color getColorByChangeType() {
    return {
          StockLogChangeType.in_: Colors.green,
          StockLogChangeType.out: Colors.red,
        }[changeType] ??
        Colors.green;
  }
}

enum StockLogChangeType { in_, out }
