import 'package:da_cashier/data/utils/api_utils.dart';

class StatsApi {
  static Future<Map<String, double>> getTodaySales() async {
    final response = await ApiUtils.getClient().get('/stats/today-sales');
    final data = response.data[0];

    data['total_sales'] = double.parse(data['total_sales']);
    data['total_transactions'] = double.parse(data['total_transactions']);

    print(response.data);

    return data;
  }
}
