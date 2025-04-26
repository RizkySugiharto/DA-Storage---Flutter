import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/category_model.dart';
import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final Category category;
  final int price;
  final int stock;
  final DateTime updatedAt;
  static final none = Product(
    id: -1,
    name: 'None',
    category: Category(id: -1, name: 'None', description: ''),
    price: 0,
    stock: 0,
    updatedAt: DateTime(0),
  );

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    required this.updatedAt,
  });

  static Product fromJSON(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      category: Category(
        id: json['category']['id'] ?? 0,
        name: json['category']['name'] ?? '',
      ),
      name: json['name'] ?? '',
      price: json['price'] ?? 0,
      stock: json['stock'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at'] ?? '00-00-00'),
    );
  }

  StockLevelEnum getStockLevel() {
    if (stock <= 0) {
      return StockLevelEnum.empty;
    } else if (stock < 10) {
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
