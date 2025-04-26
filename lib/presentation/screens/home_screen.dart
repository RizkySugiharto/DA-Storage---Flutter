import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/notifiers/navbar_notifiers.dart';
import 'package:da_storage/data/providers/stats_api.dart';
import 'package:da_storage/data/providers/transactions_api.dart';
import 'package:da_storage/presentation/utils/barcode_utils.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/transaction_card_widget.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:da_storage/data/models/transaction_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Transaction2> _recentTransactions = [];
  Map<String, double> _todaySales = {};
  Map<String, int> _stockLevels = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadRecentTransactions();
      _loadTodaySales();
      _loadStockLevels();
    });
  }

  void _loadRecentTransactions() async {
    _recentTransactions = await TransactionsApi.getRecentTransactions();
    setState(() {});
  }

  void _loadTodaySales() async {
    _todaySales = await StatsApi.getTodaySales();
    setState(() {});
  }

  void _loadStockLevels() async {
    _stockLevels = await StatsApi.getStockLevels();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

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
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 24 : 16,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSalesCard(),
                        const SizedBox(height: 24),
                        _buildActionButtons(context),
                        const SizedBox(height: 24),
                        _buildStockLevelStats(
                          normal: _stockLevels['normal']?.toDouble() ?? 0,
                          low: _stockLevels['low']?.toDouble() ?? 0,
                          empty: _stockLevels['empty']?.toDouble() ?? 0,
                        ),
                        const SizedBox(height: 24),
                        _buildRecentTransactions(context),
                        const SizedBox(height: 16),
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

  Widget _buildSalesCard() {
    final now = DateTime.now();
    final numFormat = NumberFormat.decimalPattern('ID-id');
    final dateFormat = DateFormat('MMMM d, yyyy');
    final String formattedDate = dateFormat.format(now);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsConstants.blue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Today's Sales",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: ColorsConstants.white,
                ),
              ),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorsConstants.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Sales',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: ColorsConstants.white,
                    ),
                  ),
                  Text(
                    'Rp ${numFormat.format(_todaySales['total_sales'] ?? 0)}',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsConstants.white,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Transactions',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: ColorsConstants.white,
                    ),
                  ),
                  Text(
                    numFormat.format(_todaySales['total_transactions'] ?? 0),
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: ColorsConstants.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.shopping_cart,
            label: 'New Sale',
            onTap: () {
              Navigator.pushNamed(context, RouteConstants.addTransaction);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.qr_code,
            label: 'Scan',
            onTap: () {
              BarcodeUtils.scanBarcode(context);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildActionButton(
            icon: Icons.list_alt,
            label: 'Products',
            onTap: () {
              navIndexNotifier.value = 1;
              Navigator.pushReplacementNamed(context, RouteConstants.products);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: ColorsConstants.blue.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: ColorsConstants.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.poppins(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildStockLevelStats({
    required double normal,
    required double low,
    required double empty,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Stock Level Stats',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                'View Reports',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorsConstants.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: ColorsConstants.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _stockLevels.isEmpty
                  ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                  : StockLevelChartWidget(
                    normal: _stockLevels['normal']?.toDouble() ?? 0,
                    low: _stockLevels['low']?.toDouble() ?? 0,
                    empty: _stockLevels['empty']?.toDouble() ?? 0,
                  ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _stockLevelStatsLegendItem(
                      color: const Color(0xFF4285F4),
                      label: 'Normal',
                      value: normal.toInt().toString(),
                    ),
                    _stockLevelStatsLegendItem(
                      color: const Color(0xFFEA4335),
                      label: 'Low',
                      value: low.toInt().toString(),
                    ),
                    _stockLevelStatsLegendItem(
                      color: const Color(0xFFC61100),
                      label: 'Empty',
                      value: empty.toInt().toString(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stockLevelStatsLegendItem({
    required Color color,
    required String label,
    required String value,
  }) {
    const double circleSize = 15;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text.rich(
          TextSpan(
            text: label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: ColorsConstants.black,
            ),
            children: [
              TextSpan(
                text: ' ($value)',
                style: GoogleFonts.poppins(color: ColorsConstants.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                navIndexNotifier.value = 2;
                Navigator.pushReplacementNamed(context, RouteConstants.history);
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: ColorsConstants.blue,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children:
              _recentTransactions
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TransactionCardWidget(transaction: item),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}

class StockLevelChartWidget extends StatefulWidget {
  final double normal;
  final double low;
  final double empty;

  const StockLevelChartWidget({
    super.key,
    required this.normal,
    required this.low,
    required this.empty,
  });

  @override
  State<StockLevelChartWidget> createState() => _StockLevelChartWidgetState();
}

class _StockLevelChartWidgetState extends State<StockLevelChartWidget> {
  int touchedIndex = -1;
  double total = 0;

  @override
  Widget build(BuildContext context) {
    total = widget.normal + widget.low + widget.empty;
    return SizedBox(
      height: 270,
      child: PieChart(
        PieChartData(
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: ColorsConstants.black,
              width: 5,
              strokeAlign: BorderSide.strokeAlignCenter,
            ),
          ),
          sectionsSpace: 0,
          centerSpaceRadius: 30,
          pieTouchData: PieTouchData(
            touchCallback: (event, touchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions ||
                    touchResponse == null ||
                    touchResponse.touchedSection == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex =
                    touchResponse.touchedSection!.touchedSectionIndex;
              });
            },
          ),
          sections: generateSectionsData(),
        ),
      ),
    );
  }

  List<PieChartSectionData> generateSectionsData() {
    return List.generate(3, (i) {
      final bool isTouched = i == touchedIndex;
      final double chartRadius = isTouched ? 100 : 85;
      final TextStyle chartTitleStyle = GoogleFonts.poppins(
        color: ColorsConstants.white,
        fontWeight: FontWeight.w500,
        fontSize: isTouched ? 18 : 14,
      );
      final borderSide = BorderSide(
        color: ColorsConstants.black,
        width: isTouched ? 3 : 1.5,
        strokeAlign: BorderSide.strokeAlignOutside,
      );

      switch (i) {
        case 0:
          return PieChartSectionData(
            value: widget.normal,
            title: '${(widget.normal / total * 100).round()}%',
            color: const Color(0xFF4285F4),
            radius: chartRadius,
            titleStyle: chartTitleStyle,
            borderSide: borderSide,
          );
        case 1:
          return PieChartSectionData(
            value: widget.low,
            title: '${(widget.low / total * 100).round()}%',
            color: const Color(0xFFEA4335),
            radius: chartRadius,
            titleStyle: chartTitleStyle,
            borderSide: borderSide,
          );
        case 2:
          return PieChartSectionData(
            value: widget.empty,
            title: '${(widget.empty / total * 100).round()}%',
            color: const Color(0xFFC61100),
            radius: chartRadius,
            titleStyle: chartTitleStyle,
            borderSide: borderSide,
          );
        default:
          throw Error();
      }
    });
  }
}
