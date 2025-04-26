import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/transaction_model.dart';
import 'package:da_storage/data/providers/transactions_api.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_select_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:da_storage/presentation/widgets/transaction_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedDateRange = _dateRangeOptions[1];
  String _selectedType = _typeOptions.first;
  Map<String, Set<String>> _crrntSortings = {};
  bool isLoading = false;

  static const List<String> _dateRangeOptions = [
    '1 Month',
    '3 Months',
    '6 Months',
    '1 Year',
    '2 Years',
    '3 Years',
  ];
  static const List<String> _typeOptions = [
    'All Types',
    'Purchase',
    'Sale',
    'Return',
  ];

  List<Transaction2> _transactions = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
    });
  }

  void _loadTransactions() async {
    setState(() {
      isLoading = true;
    });

    _transactions = await TransactionsApi.getAllTransactions(
      filterDateRange:
          {
            '1 Month': 1,
            '3 Months': 3,
            '6 Months': 6,
            '1 Year': 12,
            '2 Years': 24,
            '3 Years': 36,
          }[_selectedDateRange],
      filterType:
          {
            'All Types': 'all',
            'Purchase': 'purchase',
            'Sale': 'sale',
            'Return': 'return',
          }[_selectedType],
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Transaction ID': 'id',
                'Type': 'type',
                'Total Cost': 'total_cost',
                'Created Date': 'created_at',
              }[_crrntSortings['Sort By']?.first]
              : '',
      sortOrder:
          (_crrntSortings['Sort Order']?.isNotEmpty ?? false)
              ? {
                'Ascending': 'asc',
                'Descending': 'desc',
              }[_crrntSortings['Sort Order']?.first]
              : '',
    );

    setState(() {
      isLoading = false;
    });
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
              currentSortings:
                  _crrntSortings.isNotEmpty ? _crrntSortings : null,
              sortSections: {
                'Sort Order': ['Ascending', 'Descending'],
                'Sort By': [
                  'Transaction ID',
                  'Type',
                  'Total Cost',
                  'Created Date',
                ],
              },
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadTransactions();
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
      child:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                spacing: 18,
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _transactions
                        .map((item) => TransactionCardWidget(transaction: item))
                        .toList(),
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
                  _loadTransactions();
                }
              },
            ),
            const SizedBox(height: 16),
            InputSelectWidget(
              label: 'Status',
              labelStyle: inputSelectLabelStyle,
              value: _selectedType,
              options: _typeOptions,
              onChanged: (String? selected) {
                if (selected != null) {
                  setState(() {
                    _selectedType = selected;
                  });
                  _loadTransactions();
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
