import 'dart:io';

import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:rest_api_client/rest_api_client.dart';

class CustomersApi {
  static Future<List<Customer>> getAllCustomers({
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/customers',
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
      return [Customer.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Customer.fromJSON(item)).toList();

    return data;
  }

  static Future<Customer> getSingleCustomer(int id) async {
    final response = await ApiUtils.getClient().get('/customers/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode != HttpStatus.ok) {
      return Customer.none;
    }

    final data = Customer.fromJSON(resData);

    return data;
  }

  static Future<Customer> post({
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
    final response = await ApiUtils.getClient().post(
      '/customers',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.created) {
      return Customer.fromJSON(resData);
    } else {
      return Customer.none;
    }
  }

  static Future<Customer> put({
    required int id,
    required String name,
    required String email,
    required String phoneNumber,
  }) async {
    final formData = FormData.fromMap({
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
    });
    final response = await ApiUtils.getClient().put(
      '/customers/$id',
      data: formData,
    );
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode == HttpStatus.ok) {
      return Customer.fromJSON(resData);
    } else {
      return Customer.none;
    }
  }

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/customers/$id');

    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
