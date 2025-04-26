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
  late final _totalSales = _fetchTotalSales();
  List<Map<String, int>> _transactions = [];
  late final _mostUsageProductName = _fetchMostUsageProductName();
  late final _mostUsageProductStock = _fetchMostUsageProductStock();
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

  List<Map<String, double>> _fetchTotalSales() {
    return [
      {"day": 1, "sales": 120_000},
      {"day": 2, "sales": 195_000},
      {"day": 3, "sales": 150_000},
      {"day": 4, "sales": 75_000},
      {"day": 5, "sales": 105_000},
      {"day": 6, "sales": 155_000},
      {"day": 7, "sales": 120_000},
      {"day": 8, "sales": 195_000},
      {"day": 9, "sales": 55_000},
      {"day": 10, "sales": 40_000},
      {"day": 11, "sales": 65_000},
      {"day": 12, "sales": 80_000},
      {"day": 13, "sales": 75_000},
      {"day": 14, "sales": 85_000},
      {"day": 15, "sales": 75_000},
      {"day": 16, "sales": 175_000},
      {"day": 17, "sales": 70_000},
      {"day": 18, "sales": 115_000},
      {"day": 19, "sales": 55_000},
      {"day": 20, "sales": 35_000},
      {"day": 21, "sales": 95_000},
      {"day": 22, "sales": 30_000},
      {"day": 23, "sales": 120_000},
      {"day": 24, "sales": 75_000},
      {"day": 25, "sales": 90_000},
      {"day": 26, "sales": 35_000},
      {"day": 27, "sales": 115_000},
      {"day": 28, "sales": 65_000},
      {"day": 29, "sales": 60_000},
      {"day": 30, "sales": 115_000},
    ];
  }

  String _fetchMostUsageProductName() {
    return 'Egg';
  }

  List<Map<String, double>> _fetchMostUsageProductStock() {
    return [
      {"day": 1, "stock": 120},
      {"day": 2, "stock": 195},
      {"day": 3, "stock": 150},
      {"day": 4, "stock": 75},
      {"day": 5, "stock": 105},
      {"day": 6, "stock": 155},
      {"day": 7, "stock": 120},
      {"day": 8, "stock": 195},
      {"day": 9, "stock": 55},
      {"day": 10, "stock": 40},
      {"day": 11, "stock": 65},
      {"day": 12, "stock": 80},
      {"day": 13, "stock": 75},
      {"day": 14, "stock": 85},
      {"day": 15, "stock": 75},
      {"day": 16, "stock": 175},
      {"day": 17, "stock": 70},
      {"day": 18, "stock": 115},
      {"day": 19, "stock": 55},
      {"day": 20, "stock": 35},
      {"day": 21, "stock": 95},
      {"day": 22, "stock": 30},
      {"day": 23, "stock": 120},
      {"day": 24, "stock": 75},
      {"day": 25, "stock": 90},
      {"day": 26, "stock": 35},
      {"day": 27, "stock": 115},
      {"day": 28, "stock": 65},
      {"day": 29, "stock": 35},
      {"day": 30, "stock": 115},
    ];
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
    await _fetchStatsTransactions();

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  void _onExportPDF() {}
  void _onExportExcel() {}

  double _getCurrentXAxisInterval() {
    return {
          'Last Week': 1.0,
          'Last Month': 4.0,
          'Last Year': 1.0,
          'Last 3 Years': 4.0,
        }[_selectedDateRange] ??
        1.0;
  }

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
    final min =
        (_totalSales.reduce(
                  (a, b) => (a['sales'] ?? 0) < (b['sales'] ?? 0) ? a : b,
                )['sales'] ??
                0)
            .toInt();
    final isMutipleOfThree = min % 3 == 0 ? 1 : 0;
    final totalSalesDecimalCount =
        ((min.toString().length - isMutipleOfThree) / 3).floor() * 3;
    final totalSalesSpots =
        _totalSales
            .map(
              (data) => FlSpot(
                data['day'] ?? 0,
                data['sales'] ?? 0 / pow(10, totalSalesDecimalCount),
              ),
            )
            .toList();
    final max = totalSalesSpots.reduce((a, b) => a.y > b.y ? a : b).y;
    final yAxisSpacing = (max / 7).round();

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
                TextSpan(
                  text:
                      '(x Rp ${_numFormat.format(pow(10, totalSalesDecimalCount))})',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: ColorsConstants.grey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.only(right: 16),
            width: double.infinity,
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  checkToShowHorizontalLine:
                      (value) => value.round() % yAxisSpacing == 0,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: [5, 3],
                    );
                  },
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
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.round() % yAxisSpacing == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _numFormat.format(value),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
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
                minY: 0,
                maxY: max,
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
    final maxX = uniqueSpots.fold(0.0, (a, b) => a > b.x ? a : b.x);
    final maxY = uniqueSpots.fold(0.0, (a, b) => a > b.y ? a : b.y);
    final yAxisSpacing = (maxY / 7).round();

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
          Container(
            padding: const EdgeInsets.only(right: 16),
            width: double.infinity,
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  checkToShowHorizontalLine:
                      (value) =>
                          yAxisSpacing == 0 ||
                          value.round() % yAxisSpacing == 0,
                  getDrawingHorizontalLine: (value) {
                    return const FlLine(
                      color: Colors.grey,
                      strokeWidth: 1,
                      dashArray: [5, 3],
                    );
                  },
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
                      interval: _getCurrentXAxisInterval(),
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
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (yAxisSpacing == 0 ||
                            value.round() % yAxisSpacing == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _numFormat.format(value),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
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
                minY: 0,
                maxY: maxY,
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
    final min =
        (_mostUsageProductStock.reduce(
                  (a, b) => (a['stock'] ?? 0) < (b['stock'] ?? 0) ? a : b,
                )['stock'] ??
                0)
            .toInt();
    final isMutipleOfThree = min % 3 == 0 ? 1 : 0;
    final productStockDecimalCount =
        ((min.toString().length - isMutipleOfThree) / 3).floor() * 3;
    final productStockSpots =
        _mostUsageProductStock
            .map(
              (data) => FlSpot(
                data['day'] ?? 0,
                data['stock'] ?? 0 / pow(10, productStockDecimalCount),
              ),
            )
            .toList();
    final max = productStockSpots.reduce((a, b) => a.y > b.y ? a : b).y;
    final horizontalSpacing = (max / 7).round();

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
                  text:
                      '(Most Usage) ${pow(10, productStockDecimalCount) > 1 ? 'x ${_numFormat.format(pow(10, productStockDecimalCount))}' : ''}',
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
                  text: _mostUsageProductName,
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
          Container(
            padding: const EdgeInsets.only(right: 16),
            width: double.infinity,
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    if (horizontalSpacing == 0 ||
                        value.round() % horizontalSpacing == 0) {
                      return const FlLine(
                        color: Colors.grey,
                        strokeWidth: 1,
                        dashArray: [5, 3],
                      );
                    } else {
                      return const FlLine(strokeWidth: 0);
                    }
                  },
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
                      reservedSize: 35,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (horizontalSpacing == 0 ||
                            value.round() % horizontalSpacing == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              _numFormat.format(value),
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
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
                minY: 0,
                maxY: max,
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
