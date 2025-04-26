import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/models/account_model.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/models/stock_log_model.dart';
import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/models/transaction_item_model.dart';
import 'package:da_storage/data/models/transaction_model.dart';
import 'package:da_storage/data/providers/transactions_api.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({super.key});

  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  final _numFormat = NumberFormat.decimalPattern('ID-id');
  Transaction2 _transaction = Transaction2.none;
  Account _account = Account.none;
  List<TransactionItems> _items = [];
  List<StockLog> _stockLogs = [];
  Customer _customer = Customer.none;
  Supplier _supplier = Supplier.none;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchTransactionData();
    });
  }

  Future<void> fetchTransactionData() async {
    final transaction =
        ModalRoute.of(context)!.settings.arguments as Transaction2;

    final data = await TransactionsApi.getSingleTransaction(transaction.id);

    if (!mounted) {
      return;
    }

    _transaction = Transaction2(
      id: data['details']['id'],
      accountId: data['account']['id'],
      supplierId: 0,
      customerId: 0,
      type: Transaction2.getTypeFromString(data['details']['type']),
      totalCost: data['total_cost'].toDouble(),
      createdAt: DateTime.parse(data['details']['created_at']),
    );
    _account = Account(
      id: data['account']['id'],
      name: data['account']['name'],
      email: data['account']['email'],
      role: Account.getRoleByString(data['account']['role']),
    );

    if (data['customer'].isNotEmpty) {
      _customer = Customer(
        id: data['customer']['id'],
        name: data['customer']['name'],
        email: data['customer']['email'],
        phoneNumber: data['customer']['phone_number'],
      );
    } else if (data['supplier'].isNotEmpty) {
      _supplier = Supplier(
        id: data['supplier']['id'],
        name: data['supplier']['name'],
        email: data['supplier']['email'],
        phoneNumber: data['supplier']['phone_number'],
      );
    }

    data['items'].forEach((item) {
      _items.add(
        TransactionItems(
          transactionId: _transaction.id,
          productId: item['product_id'],
          unitName: item['unit_name'],
          unitPrice: item['unit_price'].toDouble(),
          quantity: item['quantity'],
          createdAt: _transaction.createdAt,
        ),
      );
    });
    data['stock_logs'].forEach((item) {
      _stockLogs.add(
        StockLog(
          transactionId: _transaction.id,
          productId: item['product_id'],
          initStock: item['init_stock'],
          changeType: StockLog.getChangeTypeFromString(item['change_type']),
          quantity: item['quantity'],
          createdAt: _transaction.createdAt,
        ),
      );
    });

    setState(() {});
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
                          label: 'Transaction Details',
                          canGoBack: true,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionDetails(),
                        const SizedBox(height: 16),
                        _buildAccountDetails(),
                        const SizedBox(height: 16),
                        _supplier != Supplier.none
                            ? _buildSupplierDetails()
                            : const SizedBox(),
                        _customer != Customer.none
                            ? _buildCustomerDetails()
                            : const SizedBox(),
                        const SizedBox(height: 16),
                        _buildTransactionItems(),
                        const SizedBox(height: 16),
                        _buildPaymentSummary(),
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

  Widget _buildTextItem(Text key, Text value) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: 16,
        runSpacing: 2,
        alignment: WrapAlignment.spaceBetween,
        children: [key, value],
      ),
    );
  }

  Widget _buildContaineredTextItem(Text key, Text value) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          key,
          const SizedBox(height: 2),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorsConstants.lightGrey,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: ColorsConstants.black, width: 1.25),
            ),
            child: value,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetails() {
    final dateFormat = DateFormat('yyyy/MM/dd - HH:mm aa');

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
            'Transaction Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              'Transaction ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _transaction.id.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTextItem(
            Text(
              'Created',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              dateFormat.format(_transaction.createdAt),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTextItem(
            Text(
              'Type',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _transaction.getTypeAsString() ?? 'none',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: _transaction.getForegroundColor(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetails() {
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
            'Account Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              'Account ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _account.id.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTextItem(
            Text(
              'Role',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _account.getRoleAsString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildContaineredTextItem(
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _account.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildContaineredTextItem(
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _account.email,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierDetails() {
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
            'Supplier Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              'Supplier ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _supplier.id.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildContaineredTextItem(
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _supplier.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildContaineredTextItem(
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _supplier.email,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildContaineredTextItem(
            Text(
              'Phone Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _supplier.phoneNumber,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerDetails() {
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
            'Customer Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              'Customer ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _customer.id.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildContaineredTextItem(
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _customer.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildContaineredTextItem(
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _customer.email,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildContaineredTextItem(
            Text(
              'Phone Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _customer.phoneNumber,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItems() {
    int itemIndex = -1;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Transaction Items',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              _getStockLogStatus(),
            ],
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children:
                _items.map((_) {
                  itemIndex += 1;
                  return _buildTransactionItem(itemIndex);
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _getStockLogStatus() {
    final stockLog = _stockLogs[0];
    final color =
        {
          StockLogChangeType.in_: Colors.green,
          StockLogChangeType.out: Colors.red,
        }[stockLog.changeType] ??
        Colors.green;

    return Row(
      children: <Widget>[
        Text(
          {StockLogChangeType.in_: 'In', StockLogChangeType.out: 'Out'}[stockLog
                  .changeType] ??
              'In',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(width: 1),
        Icon(
          {
                StockLogChangeType.in_: Icons.arrow_drop_down,
                StockLogChangeType.out: Icons.arrow_drop_up,
              }[stockLog.changeType] ??
              Icons.arrow_drop_down,
          size: 30,
          color: color,
        ),
      ],
    );
  }

  Widget _buildTransactionItem(int index) {
    final item = _items[index];
    final stockLog = _stockLogs[index];
    final color =
        {
          StockLogChangeType.in_: Colors.green,
          StockLogChangeType.out: Colors.red,
        }[stockLog.changeType] ??
        Colors.green;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ColorsConstants.lightGrey,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.unitName,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_numFormat.format(item.unitPrice)} x ${item.quantity}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Rp ${_numFormat.format(item.unitPrice * item.quantity)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Stock:  ${stockLog.initStock.toString()}  --->  ',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text:
                      '${(stockLog.changeType == StockLogChangeType.in_ ? '+' : '-')}${stockLog.quantity.toString()}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: color,
                  ),
                ),
                TextSpan(
                  text:
                      '  --->  ${(stockLog.initStock + (stockLog.quantity * (stockLog.changeType == StockLogChangeType.in_ ? 1 : -1))).toString()}',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary() {
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
            'Payment Summary',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              'Total Cost',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Rp ${_numFormat.format(_transaction.totalCost)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
