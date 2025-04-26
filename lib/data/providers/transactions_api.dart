import 'dart:convert';
import 'dart:io';
import 'package:da_storage/data/models/purchased_product_model.dart';
import 'package:da_storage/data/models/transaction_model.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:rest_api_client/rest_api_client.dart';

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

    final resData = response.response?.data as List<dynamic>;
    final data = resData.map((item) => Transaction2.fromJSON(item)).toList();

    return data;
  }

  static Future<Map<String, dynamic>> getSingleTransaction(int id) async {
    final response = await ApiUtils.getClient().get('/transactions/$id');
    final resData = response.response?.data as Map<String, dynamic>;

    if (response.response?.statusCode != HttpStatus.ok) {
      return {};
    }

    return resData;
  }

  static Future<bool> post({
    int? supplierId,
    int? customerId,
    required TransactionType type,
    required String stockChangeType,
    required Set<PurchasedProduct> items,
    required int totalCost,
  }) async {
    final data = {
      'supplier_id': supplierId,
      'customer_id': customerId,
      'type': Transaction2.getStringJSONFromType(type),
      'stock_change_type': stockChangeType,
      'items':
          items
              .map(
                (item) => {
                  'product_id': item.productId,
                  'stock': item.currentStock,
                  'unit_name': item.name,
                  'unit_price': item.price,
                  'quantity': item.quantity,
                },
              )
              .toList(),
      'total_cost': totalCost,
    };
    final response = await ApiUtils.getClient().post(
      '/transactions',
      data: jsonEncode(data),
      options: RestApiClientRequestOptions(contentType: 'application/json'),
    );

    return response.response?.statusCode == HttpStatus.resetContent;
  }
}
