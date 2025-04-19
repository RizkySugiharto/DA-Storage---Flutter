import 'dart:io';

import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/utils/api_utils.dart';
import 'package:rest_api_client/rest_api_client.dart';

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

  static Future<Category> put({
    required int id,
    required String name,
    required String description,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'description': description,
    });
    final response = await ApiUtils.getClient().put(
      '/categories/$id',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.ok) {
      return Category.fromJSON(resData);
    } else {
      return Category.none;
    }
  }

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/categories/$id');

    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
