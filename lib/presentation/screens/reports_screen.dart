import 'dart:math';

import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/providers/stats_api.dart';

import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_select_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _numFormat = NumberFormat.decimalPattern('ID-id');
  int _lowStockItems = 0;
  int _totalItems = 0;
  int _totalTransactions = 0;
  List<Map<String, dynamic>> _totalSales = [
    {'index': 0, 'sales': 0},
  ];
  List<Map<String, int>> _transactions = [
    {'index': 0, 'purchase': 0, 'sale': 0, 'return': 0},
  ];
  String _mostUsageProductName = "None";
  List<Map<String, int>> _mostUsageProductStock = [
    {'index': 0, 'stock': 0},
  ];
  bool _isLoading = false;
  late String? _selectedDateRange = _optionsDateRange[1];
  final List<String> _optionsDateRange = [
    'Last Week',
    'Last Month',
    'Last Year',
    'Last 3 Years',
  ];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchAllStatsData();
    });
  }

  Future<void> _fetchStatsTotalSales() async {
    final data = await StatsApi.getTotalSales(
      dateRange: _selectedDateRange?.toLowerCase(),
    );

    if (!mounted) return;

    setState(() {
      _totalSales = data;
    });
  }

  Future<void> _fetchMostUsageProductStock() async {
    final data = await StatsApi.getMostUsedProductStock(
      dateRange: _selectedDateRange?.toLowerCase(),
    );

    if (!mounted) return;

    setState(() {
      _mostUsageProductName = data["product_name"] as String;
      _mostUsageProductStock = data["stock_logs"] as List<Map<String, int>>;
    });
  }

  Future<void> _fetchStatsSummary() async {
    final summary = await StatsApi.getSummary(
      dateRange: _selectedDateRange?.toLowerCase(),
    );

    if (!mounted) return;

    setState(() {
      _lowStockItems = summary['low_stock_items'] ?? 0;
      _totalItems = summary['total_items'] ?? 0;
      _totalTransactions = summary['total_transactions'] ?? 0;
    });
  }

  Future<void> _fetchStatsTransactions() async {
    final data = await StatsApi.getTransactions(
      dateRange: _selectedDateRange?.toLowerCase(),
    );

    if (!mounted) return;

    setState(() {
      _transactions = data;
    });
  }

  Future<void> _fetchAllStatsData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    await _fetchStatsSummary();
    await _fetchStatsTotalSales();
    await _fetchStatsTransactions();
    await _fetchMostUsageProductStock();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _onExportPDF() {}
  void _onExportExcel() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.lightGrey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(
                          label: 'Reports & Analytics',
                          canGoBack: true,
                        ),
                        const SizedBox(height: 8),
                        _buildSummary(),
                        const SizedBox(height: 16),
                        _buildTotalSales(),
                        const SizedBox(height: 16),
                        _buildTransactions(),
                        const SizedBox(height: 16),
                        _buildProductStock(),
                        const SizedBox(height: 16),
                        _buildFilterBox(),
                        const SizedBox(height: 16),
                        _buildExportReports(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                NavbarWidget(),
              ],
            ),
            FloatingAddButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              const minWidth = 125;
              final availableWidth = constraints.maxWidth;
              final isAvailable = availableWidth >= (minWidth * 2 - 32 - 16);
              final firstItem = _buildSummaryItem(
                label: 'Low Stock Items',
                value: _lowStockItems,
              );
              final secondItem = _buildSummaryItem(
                label: 'Total Items',
                value: _totalItems,
              );

              return isAvailable
                  ? Row(
                    spacing: 16,
                    children: [
                      Expanded(child: firstItem),
                      Expanded(child: secondItem),
                    ],
                  )
                  : Column(
                    spacing: 16,
                    children: [
                      SizedBox(width: double.infinity, child: firstItem),
                      SizedBox(width: double.infinity, child: secondItem),
                    ],
                  );
            },
          ),
          const SizedBox(height: 16),
          _buildSummaryItem(
            label: 'Total Transactions',
            value: _totalTransactions,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({required String label, required int value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: ColorsConstants.black,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: ColorsConstants.lightGrey,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: ColorsConstants.black, width: 1),
          ),
          child: Text(
            _isLoading ? '....' : _numFormat.format(value),
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: ColorsConstants.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSales() {
    final maxTotalSales = _totalSales.fold(
      1,
      (a, b) => a > b['sales']!.toInt() ? a : b['sales']!.toInt(),
    );
    final maxXDigits = (log(maxTotalSales) / log(10)).ceilToDouble() + 1;
    final totalSalesSpots =
        _totalSales
            .map(
              (data) => FlSpot(
                data['index'].toDouble() ?? 0,
                data['sales'].toDouble() ?? 0,
              ),
            )
            .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Total Sales ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorsConstants.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _isLoading
              ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
              : Container(
                padding: const EdgeInsets.only(right: 16),
                width: double.infinity,
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      verticalInterval:
                          (_totalSales.length / 10).ceil().toDouble(),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval: (_totalSales.length / 10).ceil().toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _numFormat.format(value),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 5 + 11 * maxXDigits.toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  _numFormat.format(value),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    minX: 1,
                    maxX: totalSalesSpots.length.toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: totalSalesSpots,
                        color: Colors.lightGreen,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.lightGreen.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildTransactions() {
    final purchaseSpots =
        _transactions
            .map(
              (data) => FlSpot(
                data['index']?.toDouble() ?? 0,
                data['purchase']?.toDouble() ?? 0,
              ),
            )
            .toList();
    final saleSpots =
        _transactions
            .map(
              (data) => FlSpot(
                data['index']?.toDouble() ?? 0,
                data['sale']?.toDouble() ?? 0,
              ),
            )
            .toList();
    final returnSpots =
        _transactions
            .map(
              (data) => FlSpot(
                data['index']?.toDouble() ?? 0,
                data['return']?.toDouble() ?? 0,
              ),
            )
            .toList();
    final uniqueSpots = <FlSpot>{
      ...purchaseSpots,
      ...saleSpots,
      ...returnSpots,
    };
    final maxX = uniqueSpots.fold(1.0, (a, b) => a > b.x ? a : b.x);
    final maxY = uniqueSpots.fold(1.0, (a, b) => a > b.y ? a : b.y);
    final maxXDigits = (log(maxY) / log(10)).ceilToDouble() + 1;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transactions",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorsConstants.black,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 20),
              Icon(Icons.circle, size: 14, color: Colors.green),
              const SizedBox(width: 4),
              Text(
                "Purchase",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorsConstants.black,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.circle, size: 14, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                "Sale",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorsConstants.black,
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.circle, size: 14, color: Colors.blue),
              const SizedBox(width: 4),
              Text(
                "Return",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: ColorsConstants.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _isLoading
              ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
              : Container(
                padding: const EdgeInsets.only(right: 16),
                width: double.infinity,
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      verticalInterval:
                          (_transactions.length / 10).ceil().toDouble(),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval:
                              (_transactions.length / 10).ceil().toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _numFormat.format(value),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 5 + 11 * maxXDigits.toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  _numFormat.format(value),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    minX: 1,
                    maxX: maxX,
                    lineBarsData: [
                      LineChartBarData(
                        spots: purchaseSpots,
                        color: Colors.lightGreen,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.lightGreen.withValues(alpha: 0.2),
                        ),
                      ),
                      LineChartBarData(
                        spots: saleSpots,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.red.withValues(alpha: 0.2),
                        ),
                      ),
                      LineChartBarData(
                        spots: returnSpots,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildProductStock() {
    final maxProductStock = _mostUsageProductStock.fold(
      1,
      (a, b) => a > b['stock']!.toInt() ? a : b['stock']!.toInt(),
    );
    final maxXDigits = (log(maxProductStock) / log(10)).ceilToDouble() + 1;
    final productStockSpots =
        _mostUsageProductStock
            .map(
              (data) => FlSpot(
                data['index']?.toDouble() ?? 0,
                data['stock']?.toDouble() ?? 0,
              ),
            )
            .toList();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Product's Stock ",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorsConstants.black,
                  ),
                ),
                TextSpan(
                  text: '(Most Usage)',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Product's Name: ",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.grey,
                  ),
                ),
                TextSpan(
                  text:
                      _mostUsageProductName.isNotEmpty
                          ? _mostUsageProductName
                          : 'None',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _isLoading
              ? Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              )
              : Container(
                padding: const EdgeInsets.only(right: 16),
                width: double.infinity,
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      verticalInterval:
                          (_mostUsageProductStock.length / 10)
                              .ceil()
                              .toDouble(),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          interval:
                              (_mostUsageProductStock.length / 10)
                                  .ceil()
                                  .toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(
                                _numFormat.format(value),
                                style: GoogleFonts.poppins(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 5 + 11 * maxXDigits.toDouble(),
                          getTitlesWidget: (value, meta) {
                            return SideTitleWidget(
                              meta: meta,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  _numFormat.format(value),
                                  style: GoogleFonts.poppins(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border(
                        left: BorderSide(color: Colors.black),
                        bottom: BorderSide(color: Colors.black),
                      ),
                    ),
                    minX: 1,
                    maxX: productStockSpots.length.toDouble(),
                    lineBarsData: [
                      LineChartBarData(
                        spots: productStockSpots,
                        color: Colors.lightBlue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.lightBlue.withValues(alpha: 0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildFilterBox() {
    final inputSelectLabelStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: ColorsConstants.black,
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Filters',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            InputSelectWidget(
              label: 'Date Range',
              labelStyle: inputSelectLabelStyle,
              value: _selectedDateRange,
              options: _optionsDateRange,
              onChanged: (String? selected) {
                if (!_isLoading && selected != null) {
                  _selectedDateRange = selected;
                  _fetchAllStatsData();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExportReports() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Export Reports',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final availableWidth = constraints.maxWidth;
                final hasEnoughSpace = availableWidth >= (130 * 2 - 32 - 16);
                final buttonSearch = _buildButtonExport(
                  icon: Icons.file_open,
                  label: 'PDF',
                  onPressed: _onExportPDF,
                );
                final buttonScan = _buildButtonExport(
                  icon: Icons.file_open,
                  label: 'Excel',
                  onPressed: _onExportExcel,
                );

                return hasEnoughSpace
                    ? Row(
                      spacing: 16,
                      children: [
                        Expanded(child: buttonSearch),
                        Expanded(child: buttonScan),
                      ],
                    )
                    : Column(
                      spacing: 16,
                      children: [
                        SizedBox(width: double.infinity, child: buttonSearch),
                        SizedBox(width: double.infinity, child: buttonScan),
                      ],
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonExport({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(ColorsConstants.lightGrey),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        ),
        minimumSize: WidgetStatePropertyAll(const Size(130, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: ColorsConstants.black,
              width: 1.25,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: ColorsConstants.black),
          const SizedBox(width: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: ColorsConstants.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
