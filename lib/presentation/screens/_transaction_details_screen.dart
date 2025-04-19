import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/account_model.dart';
import 'package:da_cashier/data/models/purchased_product_model.dart';
import 'package:da_cashier/data/models/transaction_model.dart';
import 'package:da_cashier/data/providers/accounts_api.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
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
  Transaction2? _transaction;
  Account? _account;
  List<PurchasedProduct>? _purchasedProducts;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      fetchTransaction();
      fetchAccount();
      fetchSupplier();
      fetchCustomer();
      fetchTransactionItems();
      fetchStockLogs();
    });
  }

  void fetchTransaction() {
    _transaction = ModalRoute.of(context)!.settings.arguments as Transaction2;
  }

  void fetchAccount() async {
    _account = await AccountsApi.getSingleAccount(_transaction!.accountId);
    setState(() {});
  }

  void fetchSupplier() async {}
  void fetchCustomer() async {}
  void fetchTransactionItems() async {}
  void fetchStockLogs() async {}

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
                          label: 'Transaction Details',
                          canGoBack: true,
                        ),
                        const SizedBox(height: 8),
                        _buildTransactionInfo(),
                        const SizedBox(height: 16),
                        _buildCashierInfo(),
                        const SizedBox(height: 16),
                        _buildPurchasedProducts(),
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

  Widget _buildTransactionInfo() {
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
            'Transaction Info',
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
              _transaction?.id.toString() ?? 'none',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTextItem(
            Text(
              'Datetime',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              dateFormat.format(_transaction?.timestamp ?? DateTime.now()),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 4),
          _buildTextItem(
            Text(
              'Status',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _transaction?.getStatusAsString() ?? 'none',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color:
                    _transaction?.status == TransactionStatus.completed
                        ? const Color(0xFF047857)
                        : const Color(0xFF780404),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashierInfo() {
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
            'Cashier Info',
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
              _account?.id.toString() ?? 'none',
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
              _account?.name ?? 'none',
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
              _account?.email ?? 'none',
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

  Widget _buildPurchasedProducts() {
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
            'Purchased Products',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children:
                _purchasedProducts?.map((purchasedProduct) {
                  return _buildPurchasedProductItem(purchasedProduct);
                }).toList() ??
                [],
          ),
        ],
      ),
    );
  }

  Widget _buildPurchasedProductItem(PurchasedProduct product) {
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
            product.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rp ${_numFormat.format(product.price)} x ${product.amount}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rp ${_numFormat.format(product.price * product.amount)}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
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
              'Rp ${_numFormat.format(_transaction?.totalCost ?? 0)}',
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
