import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/data/models/purchased_product_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/utils/barcode_utils.dart';
import 'package:da_cashier/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/input_text_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() =>
      _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final double _minimumButtonAddPurchasedProductWidth = 130;
  final _numFormat = NumberFormat.decimalPattern('ID-id');
  final _buyersMoneyController = TextEditingController(text: '0');
  final _buyersChangeController = TextEditingController(text: '0');
  final _purchasedProducts = <PurchasedProduct>{};
  int _totalCost = 0;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _tryGetPurchasedProducts();
    });
  }

  @override
  void dispose() {
    _buyersChangeController.dispose();
    _buyersChangeController.dispose();
    super.dispose();
  }

  void _tryGetPurchasedProducts() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Set<Product>) {
      _addAllSelectedProducts(arguments);
    }
  }

  void _onConfirmPressed() {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Successfully create and add the transaction",
      alertType: AlertBannerType.success,
    );
  }

  void _onCancelPressed() {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Transaction has been canceled",
      alertType: AlertBannerType.info,
    );
  }

  void _onBuyersMoneyChanged(String? textValue) {
    final moneyValue =
        _buyersMoneyController.text != ''
            ? int.parse(_buyersMoneyController.text.replaceAll('.', ''))
            : 0;

    _buyersChangeController.text = _numFormat.format(moneyValue - _totalCost);
  }

  void _onBuyersChangeChanged(String? textValue) {
    final changeValue =
        _buyersChangeController.text != ''
            ? int.parse(_buyersChangeController.text.replaceAll('.', ''))
            : 0;

    _buyersMoneyController.text = _numFormat.format(_totalCost + changeValue);
  }

  void _onSearchPressed() {
    Navigator.pushNamed(context, RouteConstants.selectProducts).then((result) {
      if (result == null) return;
      _addAllSelectedProducts(result as Set<Product>);
    });
  }

  void _onScanPressed() {
    BarcodeUtils.scanBarcode(context).then((result) {
      if (result == <Product>{Product.none}) return;
      _addAllSelectedProducts(result);
    });
  }

  void _addAllSelectedProducts(Set<Product> selectedProducts) {
    setState(() {
      for (Product product in selectedProducts) {
        final newValue = PurchasedProduct(
          productId: product.id,
          name: product.name,
          price: product.price,
          amount: 1,
        );
        bool isExists = false;

        for (PurchasedProduct value in _purchasedProducts) {
          if (value.productId == newValue.productId) {
            isExists = true;
            break;
          }
        }

        if (!isExists) {
          _purchasedProducts.add(newValue);
        }

        _computeTotalCost();
      }
    });
  }

  void _computeTotalCost() {
    _totalCost = 0;
    for (PurchasedProduct item in _purchasedProducts) {
      _totalCost += item.price * item.amount;
    }
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
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                  showScanner: false,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Create Transaction'),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Set to 0 to remove purchased product',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: ColorsConstants.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildPurchasedProducts(),
                        const SizedBox(height: 16),
                        _buildPaymentSummary(),
                        const SizedBox(height: 16),
                        _buildBuyersMoney(),
                        const SizedBox(height: 16),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Submit',
                          cancelLabel: 'Cancel',
                          onConfirmPressed: _onConfirmPressed,
                          onCancelPressed: _onCancelPressed,
                        ),
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
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children:
                _purchasedProducts.isNotEmpty
                    ? _purchasedProducts.map((purchasedProduct) {
                      return _buildPurchasedProductItem(purchasedProduct);
                    }).toList()
                    : [
                      Text(
                        'Please add one or more purchased product.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
          ),
          const SizedBox(height: 24),
          Text(
            'Add Purchased Product',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),
          _buildAddPurchasedProductOptions(),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rp ${_numFormat.format(product.price)} / unit',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Rp ${_numFormat.format(product.price * product.amount)}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 100,
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  fillColor: ColorsConstants.white,
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: product.amount.toString(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (value) {
                  setState(() {
                    product.amount = int.parse(value == '' ? '0' : value);
                    _computeTotalCost();
                  });
                },
                onEditingComplete: () {
                  if (product.amount > 0) return;
                  setState(() {
                    _purchasedProducts.remove(product);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPurchasedProductOptions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final hasEnoughSpace =
            availableWidth >=
            (_minimumButtonAddPurchasedProductWidth * 2 - 32 - 16);
        final buttonSearch = _buildButtonAddPurchasedProduct(
          icon: Icons.search,
          label: 'Search',
          onPressed: _onSearchPressed,
        );
        final buttonScan = _buildButtonAddPurchasedProduct(
          icon: Icons.qr_code,
          label: 'Scan',
          onPressed: _onScanPressed,
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
    );
  }

  Widget _buildButtonAddPurchasedProduct({
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
        minimumSize: WidgetStatePropertyAll(
          Size(_minimumButtonAddPurchasedProductWidth, 0),
        ),
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
              'Rp ${_numFormat.format(_totalCost)}',
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

  Widget _buildBuyersMoney() {
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
            "Buyer's Money",
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          InputTextWidget(
            label: 'Money',
            textController: _buyersMoneyController,
            enablePriceLabel: true,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            onChanged: _onBuyersMoneyChanged,
          ),
          const SizedBox(height: 12),
          InputTextWidget(
            label: 'Change',
            textController: _buyersChangeController,
            enablePriceLabel: true,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            onChanged: _onBuyersChangeChanged,
          ),
        ],
      ),
    );
  }
}
