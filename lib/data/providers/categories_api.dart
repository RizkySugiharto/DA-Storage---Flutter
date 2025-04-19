import 'dart:io';

import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/utils/api_utils.dart';

class CategoriesApi {
  static Future<List<Category>> getAllCategories({String? search}) async {
    final response = await ApiUtils.getClient().get(
      '/categories',
      queryParameters: {'search': search},
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.statusCode != HttpStatus.ok) {
      return [Category.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Category.fromJSON(item)).toList();

    return data;
  }

  static Future<Category> getSingleCategory(int id) async {
    final response = await ApiUtils.getClient().get('/categories/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.statusCode != HttpStatus.ok) {
      return Category.none;
    }

    final data = Category.fromJSON(resData);

    return data;
  }
}
