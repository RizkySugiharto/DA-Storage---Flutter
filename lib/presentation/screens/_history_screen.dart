import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/transaction_model.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/input_select_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:da_cashier/presentation/widgets/sorts_dialog_widget.dart';
import 'package:da_cashier/presentation/widgets/transaction_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedDateRange = _dateRangeOptions.first;
  String _selectedStatus = _statusOptions.first;

  static const List<String> _dateRangeOptions = [
    'Today',
    'Last Week',
    'Last Month',
    'Last 3 Months',
    'Last 6 Months',
    'Last Year',
    'Last 2 Years',
    'Last 3 Years',
  ];
  static const List<String> _statusOptions = [
    'All Status',
    'Completed',
    'Cancelled',
  ];

  final Map<String, List<Transaction>> _transactionSections = {
    'February 2024': [
      Transaction(
        id: 1,
        totalCost: 56_000,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
      Transaction(
        id: 1,
        totalCost: 56_000,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
    ],
    'January 2024': [
      Transaction(
        id: 1,
        totalCost: 56_000,
        status: TransactionStatus.canceled,
        timestamp: DateTime.now(),
      ),
      Transaction(
        id: 1,
        totalCost: 56_000,
        status: TransactionStatus.completed,
        timestamp: DateTime.now(),
      ),
    ],
  };

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
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(
                          label: 'Transaction History',
                          actionButtons: [
                            _buildAnalyticsIconButton(),
                            _buildSortIconButton(),
                          ],
                        ),
                        _buildFilterBox(),
                        _buildTransactionList(),
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

  IconButton _buildSortIconButton() {
    return IconButton(
      onPressed: () {
        showDialog(
          useSafeArea: true,
          context: context,
          builder: (BuildContext dialogContext) {
            return SortsDialogWidget(
              dialogContext: dialogContext,
              title: 'Sorts',
              sortSections: {
                'Sort Order': {
                  'Ascending': SortOrderEnum.ascending,
                  'Descending': SortOrderEnum.descending,
                },
                'Sort By': {
                  'Transaction ID': SortByEnum.transactionId,
                  'Total Price': SortByEnum.totalPrice,
                  'Date Time': SortByEnum.dateTime,
                  'Status': SortByEnum.status,
                },
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  IconButton _buildAnalyticsIconButton() {
    return IconButton(
      onPressed: () {
        Navigator.pushNamed(context, RouteConstants.reports);
      },
      icon: Icon(Icons.analytics_outlined, size: 34, weight: 5),
    );
  }

  Widget _buildTransactionList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 18,
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            _transactionSections.entries.map((section) {
              return Column(
                spacing: 14,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section.key,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorsConstants.black,
                    ),
                  ),
                  Column(
                    spacing: 14,
                    children:
                        section.value
                            .map(
                              (transaction) => TransactionCardWidget(
                                transaction: transaction,
                              ),
                            )
                            .toList(),
                  ),
                ],
              );
            }).toList(),
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
            InputSelectWidget(
              label: 'Date Range',
              labelStyle: inputSelectLabelStyle,
              value: _selectedDateRange,
              options: _dateRangeOptions,
              onChanged: (String? selected) {
                if (selected != null) {
                  setState(() {
                    _selectedDateRange = selected;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            InputSelectWidget(
              label: 'Status',
              labelStyle: inputSelectLabelStyle,
              value: _selectedStatus,
              options: _statusOptions,
              onChanged: (String? selected) {
                if (selected != null) {
                  setState(() {
                    _selectedStatus = selected;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

enum SortOrderEnum { ascending, descending }

enum SortByEnum { transactionId, totalPrice, dateTime, status }
