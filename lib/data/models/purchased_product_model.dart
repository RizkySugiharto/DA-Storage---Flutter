class PurchasedProduct {
  final int productId;
  final String name;
  final int price;
  int amount;

  PurchasedProduct({
    required this.productId,
    required this.name,
    required this.price,
    this.amount = 1,
  });
}
