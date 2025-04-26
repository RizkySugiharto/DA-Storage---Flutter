import 'dart:io';

import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:rest_api_client/rest_api_client.dart';

class SuppliersApi {
  static Future<List<Supplier>> getAllSuppliers({
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/suppliers',
      queryParameters: {
        'search': search,
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      },
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.response?.statusCode != HttpStatus.ok) {
      return [Supplier.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Supplier.fromJSON(item)).toList();

    return data;
  }

  static Future<Supplier> getSingleSupplier(int id) async {
    final response = await ApiUtils.getClient().get('/suppliers/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode != HttpStatus.ok) {
      return Supplier.none;
    }

    final data = Supplier.fromJSON(resData);

    return data;
  }

  static Future<Supplier> post({
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
    final response = await ApiUtils.getClient().post(
      '/suppliers',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.created) {
      return Supplier.fromJSON(resData);
    } else {
      return Supplier.none;
    }
  }

  static Future<Supplier> put({
    required int id,
    required String name,
    String? email,
    String? phoneNumber,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
    final response = await ApiUtils.getClient().put(
      '/suppliers/$id',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.ok) {
      return Supplier.fromJSON(resData);
    } else {
      return Supplier.none;
    }
  }

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/suppliers/$id');

    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
