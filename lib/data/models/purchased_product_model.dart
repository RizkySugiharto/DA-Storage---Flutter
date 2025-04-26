class PurchasedProduct {
  final int productId;
  final String name;
  final int currentStock;
  final int price;
  int quantity;

  PurchasedProduct({
    required this.productId,
    required this.name,
    required this.currentStock,
    required this.price,
    this.quantity = 1,
  });
}
