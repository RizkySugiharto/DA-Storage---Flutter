import 'package:da_cashier/data/utils/api_utils.dart';

class StatsApi {
  static Future<Map<String, double>> getTodaySales() async {
    final response = await ApiUtils.getClient().get('/stats/today-sales');
    final resData = response.response?.data as Map<String, dynamic>;
    final data = <String, double>{};

    data['total_sales'] = resData['total_sales']?.toDouble() ?? 0;
    data['total_transactions'] = resData['total_transactions']?.toDouble() ?? 0;

    return data;
  }

  static Future<Map<String, int>> getStockLevels() async {
    final response = await ApiUtils.getClient().get('/stats/stock-levels');
    final resData = response.response?.data as Map<String, dynamic>;
    final data = <String, int>{};

    data['empty'] = resData['empty'] ?? 0;
    data['low'] = resData['low'] ?? 0;
    data['normal'] = resData['normal'] ?? 0;
    data['total'] = resData['total'] ?? 0;

    return data;
  }
}
