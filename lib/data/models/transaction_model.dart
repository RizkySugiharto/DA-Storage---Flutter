import 'package:flutter/material.dart';

class Transaction {
  final int id;
  final double totalCost;
  final DateTime timestamp;
  final TransactionStatus status;

  Transaction({
    required this.id,
    required this.totalCost,
    required this.timestamp,
    required this.status,
  });

  String getStatusAsString() {
    return {
          TransactionStatus.completed: 'Completed',
          TransactionStatus.canceled: 'Canceled',
        }[status] ??
        'none';
  }
}

class Transaction2 {
  final int id;
  final int accountId;
  final int supplierId;
  final int customerId;
  final TransactionType type;
  final double totalCost;
  final DateTime createdAt;
  static final none = Transaction2(
    id: 0,
    accountId: 0,
    customerId: 0,
    supplierId: 0,
    type: TransactionType.return_,
    totalCost: 0,
    createdAt: DateTime(0),
  );

  Transaction2({
    required this.id,
    required this.accountId,
    required this.supplierId,
    required this.customerId,
    required this.type,
    required this.totalCost,
    required this.createdAt,
  });

  static Transaction2 fromJSON(Map<String, dynamic> json) {
    return Transaction2(
      id: json['id'] ?? 0,
      accountId: json['account_id'] ?? 0,
      supplierId: json['supplier_id'] ?? 0,
      customerId: json['customer_id'] ?? 0,
      type: Transaction2.getTypeFromString(json['type'] ?? ''),
      totalCost: json['total_cost'].toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? '1111-11-11'),
    );
  }

  static TransactionType getTypeFromString(String type) {
    return {
          'purchase': TransactionType.purchase,
          'sale': TransactionType.sale,
          'return': TransactionType.return_,
        }[type] ??
        TransactionType.return_;
  }

  static String getStringJSONFromType(TransactionType type) {
    return {
          TransactionType.purchase: 'purchase',
          TransactionType.sale: 'sale',
          TransactionType.return_: 'return',
        }[type] ??
        'purchase';
  }

  String? getTypeAsString() {
    return {
      TransactionType.purchase: 'Purchase',
      TransactionType.sale: 'Sale',
      TransactionType.return_: 'Return',
    }[type];
  }

  Color? getForegroundColor() {
    return {
      TransactionType.purchase: Colors.green,
      TransactionType.sale: Colors.red,
      TransactionType.return_: Colors.blue,
    }[type];
  }

  Color? getBackgroundColor() {
    return {
      TransactionType.purchase: Colors.lightGreenAccent.withValues(alpha: 0.4),
      TransactionType.sale: Colors.redAccent.withValues(alpha: 0.2),
      TransactionType.return_: Colors.lightBlueAccent.withValues(alpha: 0.2),
    }[type];
  }
}

enum TransactionType { purchase, sale, return_ }

enum TransactionStatus { completed, canceled }
