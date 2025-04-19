import 'dart:io';

import 'package:da_cashier/data/models/account_model.dart';
import 'package:da_cashier/data/utils/api_utils.dart';

class AccountsApi {
  static Future<List<Account>> getAllAccounts({
    String? search,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/accounts',
      queryParameters: {
        'search': search ?? '',
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      },
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.statusCode != HttpStatus.ok) {
      return [Account.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Account.fromJSON(item)).toList();

    return data;
  }

  static Future<Account> getSingleAccount(int id) async {
    final response = await ApiUtils.getClient().get('/accounts/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.statusCode != HttpStatus.ok) {
      return Account.none;
    }

    final data = Account.fromJSON(resData);

    return data;
  }

  static Future<bool> delete(int id) async {
    final response = await ApiUtils.getClient().delete('/accounts/$id');

    return response.statusCode == HttpStatus.ok;
  }
}
