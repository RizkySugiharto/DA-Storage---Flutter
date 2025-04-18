import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final Category category;
  final int price;
  final int stock;
  final DateTime lastUpdated;
  static final none = Product(
    id: -1,
    name: 'None',
    category: Category(id: -1, name: 'None', description: ''),
    price: 0,
    stock: 0,
    lastUpdated: DateTime(0),
  );

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.lastUpdated,
  });

  StockLevelEnum getStockLevel() {
    if (stock <= 0) {
      return StockLevelEnum.empty;
    } else if (stock <= 10) {
      return StockLevelEnum.low;
    } else {
      return StockLevelEnum.normal;
    }
  }

  Color getStockLevelColor() {
    switch (getStockLevel()) {
      case StockLevelEnum.normal:
        return ColorsConstants.grey;
      case StockLevelEnum.low:
        return const Color(0xFFEA4335);
      case StockLevelEnum.empty:
        return const Color(0xFF5E1F1F);
    }
  }
}

enum StockLevelEnum { normal, low, empty }
