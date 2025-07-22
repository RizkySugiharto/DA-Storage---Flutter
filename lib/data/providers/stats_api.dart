import 'package:da_storage/data/utils/api_utils.dart';

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

  static Future<Map<String, int>> getSummary({String? dateRange}) async {
    final response = await ApiUtils.getClient().get(
      '/stats/summary',
      queryParameters: {'date_range': dateRange},
    );
    final resData = response.response?.data as Map<String, dynamic>;
    final data = <String, int>{};

    data['low_stock_items'] = resData['low_stock_items'] ?? 0;
    data['total_items'] = resData['total_items'] ?? 0;
    data['total_transactions'] = resData['total_transactions'] ?? 0;

    return data;
  }

  static Future<List<Map<String, int>>> getTransactions({
    String? dateRange,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/stats/transactions',
      queryParameters: {'date_range': dateRange},
    );
    final resData = response.response?.data as List<dynamic>;
    final List<Map<String, int>> data = [];

    for (var item in resData) {
      data.add({
        'index': item['index'] ?? 0,
        'purchase': item['purchase'] ?? 0,
        'sale': item['sale'] ?? 0,
        'return': item['return'] ?? 0,
      });
    }

    return data;
  }

  static Future<List<Map<String, dynamic>>> getTotalSales({
    String? dateRange,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/stats/total-sales',
      queryParameters: {'date_range': dateRange},
    );
    final resData = response.response?.data as List<dynamic>;
    final List<Map<String, dynamic>> data = [];

    for (var item in resData) {
      data.add({'index': item['index'] ?? 0, 'sales': item['sales'] ?? 0});
    }

    return data;
  }

  static Future<Map<String, Object>> getMostUsedProductStock({
    String? dateRange,
  }) async {
    final response = await ApiUtils.getClient().get(
      '/stats/most-used-product-stock',
      queryParameters: {'date_range': dateRange},
    );
    final resData = response.response?.data as Map<String, dynamic>;
    String productName = "None";
    final List<Map<String, int>> stockLogs = [];

    productName = resData["product"]["name"] ?? "None";
    for (var item in resData["stock_logs"]) {
      stockLogs.add({'index': item['index'] ?? 0, 'stock': item['stock'] ?? 0});
    }

    return {"product_name": productName, "stock_logs": stockLogs};
  }
}
