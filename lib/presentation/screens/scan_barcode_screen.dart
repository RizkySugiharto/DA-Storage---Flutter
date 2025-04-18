import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/utils/barcode_utils.dart';
import 'package:da_cashier/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ScanBarcodeScreen extends StatelessWidget {
  late Product _productResult;
  late String _barcodeResult;
  late bool _createTransaction;
  final _numFormat = NumberFormat.decimalPattern('ID-id');

  ScanBarcodeScreen({super.key});

  Product _fetchProduct(int id) {
    return Product(
      id: 1,
      name: 'Coffe Cup',
      category: Category(id: 1, name: 'Foods & Drinks', description: 'foods'),
      price: 5_000,
      stock: 50,
      lastUpdated: DateTime.now(),
    );
  }

  void _onUpdatePressed(BuildContext context) {
    Navigator.pushNamed(
      context,
      RouteConstants.editProduct,
      arguments: _productResult.id,
    );
  }

  void _onDeletePressed(BuildContext context) {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: 'Successfully delete the scanned product.',
      alertType: AlertBannerType.success,
    );
  }

  void _onConfirmPressed(BuildContext context) {
    if (_createTransaction) {
      Navigator.pushReplacementNamed(
        context,
        RouteConstants.createTransaction,
        result: <Product>{_productResult},
        arguments: <Product>{_productResult},
      );
    } else {
      Navigator.pop(context, <Product>{_productResult});
    }
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _setupProductResult(BuildContext context) {
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _barcodeResult = arguments['barcodeResult'] as String;
    _createTransaction = arguments['createTransaction'] as bool;
    _productResult = _fetchProduct(int.parse(_barcodeResult.substring(1, 7)));
  }

  @override
  Widget build(BuildContext context) {
    _setupProductResult(context);

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
                          label: 'Scan Barcode',
                          canGoBack: true,
                        ),
                        const SizedBox(height: 8),
                        _buildScanResult(context),
                        const SizedBox(height: 16),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Add',
                          cancelLabel: 'Cancel',
                          onConfirmPressed: () => _onConfirmPressed(context),
                          onCancelPressed: () => _onCancelPressed(context),
                        ),
                        const SizedBox(height: 16),
                        _buildCreateTransactionInfoText(),
                        const SizedBox(height: 54),
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

  Widget _buildScanResult(BuildContext context) {
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
            'Scan Result',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Center(child: BarcodeUtils.generateBarcode(_barcodeResult)),
          ),
          const SizedBox(height: 24),
          Text(
            'Product Info',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildTextItem(
            Text(
              'Product ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _productResult.id.toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 2),
          _buildTextItem(
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _productResult.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 2),
          _buildTextItem(
            Text(
              'Category',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _productResult.category.name,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 2),
          _buildTextItem(
            Text(
              'Price',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              'Rp ${_numFormat.format(_productResult.price)}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 2),
          _buildTextItem(
            Text(
              'Stock',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _numFormat.format(_productResult.stock),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: _productResult.getStockLevelColor(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildActionButton(
                label: 'Update',
                foregroundColor: ColorsConstants.blue,
                backgroundColor: ColorsConstants.blue.withValues(alpha: 0.2),
                onPressed: () => _onUpdatePressed(context),
              ),
              _buildActionButton(
                label: 'Delete',
                foregroundColor: Colors.red,
                backgroundColor: Colors.red.withValues(alpha: 0.2),
                onPressed: () => _onDeletePressed(context),
              ),
            ],
          ),
        ],
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

  Widget _buildActionButton({
    required String label,
    required Color foregroundColor,
    required Color backgroundColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        ),
        shadowColor: WidgetStatePropertyAll(ColorsConstants.white),
        foregroundColor: WidgetStatePropertyAll(foregroundColor),
        backgroundColor: WidgetStatePropertyAll(backgroundColor),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: foregroundColor, width: 1.5),
          ),
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w400),
      ),
    );
  }

  Widget _buildCreateTransactionInfoText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: Text.rich(
        textAlign: TextAlign.center,
        TextSpan(
          children: [
            TextSpan(
              text: 'Click ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: '"Add" ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'to ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'start a transaction ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            TextSpan(
              text: 'or ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
            TextSpan(
              text: 'add as purchased product.',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
