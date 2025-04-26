import 'dart:io';

import 'package:da_storage/data/models/product_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:rest_api_client/rest_api_client.dart';

class ProductsApi {
  static Future<List<Product>> getAllProducts({
    String? search,
    List<String>? filterStockLevel,
    List<int>? filterCategoryId,
    String? filterUpdatedDate,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/products',
      queryParameters: {
        'search': search ?? '',
        'filter_stock_level': filterStockLevel?.join(','),
        'filter_category_id': filterCategoryId?.join(','),
        'filter_updated_date': filterUpdatedDate ?? '',
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      },
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.statusCode != HttpStatus.ok) {
      return [Product.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Product.fromJSON(item)).toList();

    return data;
  }

  static Future<Product> getSingleProduct(int id) async {
    final response = await ApiUtils.getClient().get('/products/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.statusCode != HttpStatus.ok) {
      return Product.none;
    }

    final data = Product.fromJSON(resData);

    return data;
  }

  static Future<Product> post({
    required String name,
    required int categoryId,
    required int price,
    required int stock,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'category_id': categoryId,
      'price': price,
      'stock': stock,
    });
    final response = await ApiUtils.getClient().post(
      '/products/',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.statusCode == HttpStatus.ok) {
      return Product.fromJSON(resData);
    } else {
      return Product.none;
    }
  }

  static Future<Product> put({
    required int id,
    required String name,
    required int categoryId,
    required int price,
    required int stock,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'category_id': categoryId,
      'price': price,
      'stock': stock,
    });
    final response = await ApiUtils.getClient().put(
      '/products/$id',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.statusCode == HttpStatus.ok) {
      return Product.fromJSON(resData);
    } else {
      return Product.none;
    }
  }

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/products/$id');

    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
