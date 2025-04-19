import 'dart:io';

import 'package:da_cashier/data/models/transaction_model.dart';
import 'package:da_cashier/data/utils/api_utils.dart';

class TransactionsApi {
  static Future<List<Transaction2>> getAllTransactions({
    int? filterDateRange,
    String? filterType,
    String? sortBy,
    String? sortOrder,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/transactions',
      queryParameters: {
        'filter_date_range': filterDateRange ?? 3,
        'filter_type': filterType ?? '',
        'sort_by': sortBy ?? '',
        'sort_order': sortOrder ?? '',
      },
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    if (response.statusCode != HttpStatus.ok) {
      return [Transaction2.none];
    }

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Transaction2.fromJSON(item)).toList();

    return data;
  }

  static Future<List<Transaction2>> getRecentTransactions() async {
    final response = await ApiUtils.getClient().get(
      '/transactions',
      queryParameters: {'recent': true},
    );

    if (response.response?.data.length < 1) {
      return [];
    }

    final resData = response.response?.data as List<Map<String, dynamic>>;
    final data = resData.map((item) => Transaction2.fromJSON(item)).toList();

    return data;
  }
}
