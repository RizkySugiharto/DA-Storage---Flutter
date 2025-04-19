class TransactionItems {
  final int transactionId;
  final int productId;
  final String unitName;
  final double unitPrice;
  int quantity;
  final DateTime createdAt;

  TransactionItems({
    required this.transactionId,
    required this.productId,
    required this.unitName,
    required this.unitPrice,
    required this.quantity,
    required this.createdAt,
  });

  static TransactionItems fromJSON(Map<String, dynamic> json) {
    return TransactionItems(
      transactionId: json['transaction_id'] ?? 0,
      productId: json['product_id'] ?? 0,
      unitName: json['unit_name'] ?? '',
      unitPrice: json['unit_price'].toDouble() ?? 0,
      quantity: json['quantity'] ?? 0,
      createdAt: DateTime.parse(json['created_at'] ?? '1111-11-11'),
    );
  }
}
