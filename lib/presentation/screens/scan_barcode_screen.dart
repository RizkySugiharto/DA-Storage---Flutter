import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/product_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/products_api.dart';
import 'package:da_storage/data/static/account_static.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/utils/barcode_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ScanBarcodeScreen extends StatefulWidget {
  const ScanBarcodeScreen({super.key});

  @override
  State<ScanBarcodeScreen> createState() => _ScanBarcodeScreenState();
}

class _ScanBarcodeScreenState extends State<ScanBarcodeScreen> {
  final _numFormat = NumberFormat.decimalPattern('ID-id');
  Product _productResult = Product.none;
  String _barcodeResult = '';
  bool _createTransaction = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _setupProductResult();
    });
  }

  Future<Product> _fetchProduct(int id) async {
    final product = await ProductsApi.getSingleProduct(id);

    if (mounted && product == Product.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: 'Product isn\'t exists',
        alertType: AlertBannerType.error,
      );
    }

    return product;
  }

  void _onUpdatePressed() {
    Navigator.pushNamed(
      context,
      RouteConstants.editProduct,
      arguments: _productResult.id,
    );
  }

  Future<void> _onDeletePressed() async {
    final isSuccess = await ProductsApi.delete(_productResult.id);

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully delete the product. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to delete the product",
        alertType: AlertBannerType.error,
      );
    }
  }

  void _onConfirmPressed() {
    if (_createTransaction) {
      Navigator.pushReplacementNamed(
        context,
        RouteConstants.addTransaction,
        result: <Product>{_productResult},
        arguments: <Product>{_productResult},
      );
    } else {
      Navigator.pop(context, <Product>{_productResult});
    }
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  Future<void> _setupProductResult() async {
    setState(() {
      _isLoading = true;
    });

    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    _barcodeResult = arguments['barcodeResult'] as String;
    _createTransaction = arguments['createTransaction'] as bool;
    _productResult = await _fetchProduct(
      int.parse(_barcodeResult.substring(1, 7)),
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _setupProductResult();
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
                  child: RefreshIndicator(
                    onRefresh: _onRefresh,
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
                            cancelLabel: 'Back',
                            onConfirmPressed: () => _onConfirmPressed(),
                            onCancelPressed: () => _onCancelPressed(),
                          ),
                          const SizedBox(height: 16),
                          _buildCreateTransactionInfoText(),
                          const SizedBox(height: 54),
                        ],
                      ),
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
            child: Center(
              child:
                  _isLoading
                      ? CircularProgressIndicator()
                      : BarcodeUtils.generateBarcode(_barcodeResult),
            ),
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
                fontWeight: FontWeight.w400,
                color: _productResult.getStockLevelColor(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          AccountStatic.isAdmin()
              ? (_isLoading
                  ? CircularProgressIndicator()
                  : Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildActionButton(
                        label: 'Update',
                        foregroundColor: ColorsConstants.blue,
                        backgroundColor: ColorsConstants.blue.withValues(
                          alpha: 0.2,
                        ),
                        onPressed: () => _onUpdatePressed(),
                      ),
                      _buildActionButton(
                        label: 'Delete',
                        foregroundColor: Colors.red,
                        backgroundColor: Colors.red.withValues(alpha: 0.2),
                        onPressed: () => _onDeletePressed(),
                      ),
                    ],
                  ))
              : const SizedBox(),
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
