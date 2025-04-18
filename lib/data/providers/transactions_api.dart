import 'package:da_cashier/data/models/transaction_model.dart';
import 'package:da_cashier/data/utils/api_utils.dart';

class TransactionsApi {
  static Future<List<Transaction2>> getRecentTransactions() async {
    final response = await ApiUtils.getClient().get(
      '/transactions',
      queryParameters: {'recent': true},
    );

    print(response.data);

    return response.data.map((item) => Transaction2.fromJSON(item));
  }
}
