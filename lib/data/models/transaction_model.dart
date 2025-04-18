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
      accountId: json['accountId'] ?? 0,
      supplierId: json['supplierId'] ?? 0,
      customerId: json['customerId'] ?? 0,
      type: Transaction2.getTypeFromString(json['type'] ?? ''),
      totalCost: double.tryParse(json['totalCost']) ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
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
      TransactionType.purchase: Colors.lightGreenAccent,
      TransactionType.sale: Colors.redAccent.withValues(alpha: 0.6),
      TransactionType.return_: Colors.lightBlueAccent,
    }[type];
  }
}

enum TransactionType { purchase, sale, return_ }

enum TransactionStatus { completed, canceled }
