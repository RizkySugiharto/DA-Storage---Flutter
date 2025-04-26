import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/models/product_model.dart';
import 'package:da_storage/data/models/purchased_product_model.dart';
import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/models/transaction_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/transactions_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/utils/barcode_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_select_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final double _minimumButtonAddPurchasedProductWidth = 130;
  final _numFormat = NumberFormat.decimalPattern('ID-id');
  final _purchasedProducts = <PurchasedProduct>{};
  Supplier _selectedSupplier = Supplier.none;
  Customer _selectedCustomer = Customer.none;
  String? _selectedTransactionType = 'Purchase';
  String _selectedStockChangeType = 'in';
  int _totalCost = 0;
  bool _isLoading = false;
  final Key _purchasedItemKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _tryGetPurchasedProducts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _tryGetPurchasedProducts() {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    if (arguments != null && arguments is Set<Product>) {
      _addAllSelectedProducts(arguments);
    }
  }

  Future<void> _onConfirmPressed() async {
    if (_selectedSupplier == Supplier.none &&
        _selectedCustomer == Customer.none) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Please choose supplier or customer at first.",
        alertType: AlertBannerType.error,
      );
      return;
    }

    if (_purchasedProducts.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Please add at least 1 product to be purchased.",
        alertType: AlertBannerType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _computeTotalCost();

    final isSuccess = await TransactionsApi.post(
      supplierId:
          _selectedSupplier != Supplier.none ? _selectedSupplier.id : null,
      customerId:
          _selectedCustomer != Customer.none ? _selectedCustomer.id : null,
      type: Transaction2.getTypeFromString(
        _selectedTransactionType?.toLowerCase() ?? 'purchase',
      ),
      stockChangeType: _selectedStockChangeType.toLowerCase(),
      items: _purchasedProducts,
      totalCost: _totalCost,
    );

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message:
            "Successfully add the transaction. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to add the transaction.",
        alertType: AlertBannerType.error,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCancelPressed() {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Transaction has been canceled",
      alertType: AlertBannerType.info,
    );
  }

  void _onSearchSupplierPressed() {
    Navigator.pushNamed(context, RouteConstants.selectSupplier).then((result) {
      if (result == Supplier.none) return;
      _selectedSupplier = result as Supplier;
      setState(() {});
    });
  }

  void _onSearchCustomerPressed() {
    Navigator.pushNamed(context, RouteConstants.selectCustomer).then((result) {
      if (result == Customer.none) return;
      _selectedCustomer = result as Customer;
      setState(() {});
    });
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
          currentStock: product.stock,
          price: product.price,
          quantity: 1,
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
      _totalCost += item.price * item.quantity;
    }
  }

  String _getCurrentTargetLabel() {
    return {'in': 'Supplier', 'out': 'Customer'}[_selectedStockChangeType] ??
        'Supplier';
  }

  int _getCurrentTargetID() {
    return {
          'in': _selectedSupplier.id,
          'out': _selectedCustomer.id,
        }[_selectedStockChangeType] ??
        _selectedSupplier.id;
  }

  String _getCurrentTargetName() {
    return {
          'in': _selectedSupplier.name,
          'out': _selectedCustomer.name,
        }[_selectedStockChangeType] ??
        _selectedSupplier.name;
  }

  String _getCurrentTargetEmail() {
    return {
          'in': _selectedSupplier.email,
          'out': _selectedCustomer.email,
        }[_selectedStockChangeType] ??
        _selectedSupplier.email;
  }

  String _getCurrentTargetPhoneNumber() {
    return {
          'in': _selectedSupplier.phoneNumber,
          'out': _selectedCustomer.phoneNumber,
        }[_selectedStockChangeType] ??
        _selectedSupplier.phoneNumber;
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
                HeaderWidget(showScanner: false),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Add Transaction'),
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
                        _buildTransactionDetails(),
                        const SizedBox(height: 16),
                        _buildTargetDetails(),
                        const SizedBox(height: 16),
                        _buildPurchasedProducts(),
                        const SizedBox(height: 16),
                        _buildPaymentSummary(),
                        const SizedBox(height: 16),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Submit',
                          cancelLabel: 'Cancel',
                          isLoading: _isLoading,
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
          InputSelectWidget(
            label: 'Select Transaction Type',
            options: ['Purchase', 'Sale', 'Return'],
            value: _selectedTransactionType,
            onChanged: (value) {
              _selectedTransactionType = value;

              if (_selectedTransactionType == 'Purchase') {
                _selectedStockChangeType = 'in';
              } else if (_selectedTransactionType == 'Sale') {
                _selectedStockChangeType = 'out';
              }
            },
            hint: 'Choose only one type',
          ),
          const SizedBox(height: 24),
          Text(
            'Select ${_getCurrentTargetLabel()}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorsConstants.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildSelectTargetButton(),
          const SizedBox(height: 24),
          Text(
            'Select Stock Change Type',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: ColorsConstants.black,
            ),
          ),
          const SizedBox(height: 8),
          _buildStockChangeTypeOptions(),
        ],
      ),
    );
  }

  Widget _buildSelectTargetButton() {
    return ElevatedButton(
      onPressed:
          {
            'in': _onSearchSupplierPressed,
            'out': _onSearchCustomerPressed,
          }[_selectedStockChangeType],
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(ColorsConstants.lightGrey),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
        minimumSize: WidgetStatePropertyAll(
          Size(_minimumButtonAddPurchasedProductWidth, 0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: ColorsConstants.black,
              width: 1.3,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            {
              'in': Icons.warehouse,
              'out': Icons.person,
            }[_selectedStockChangeType],
            size: 30,
            color: ColorsConstants.black,
          ),
          const SizedBox(width: 8),
          Text(
            'Search ${_getCurrentTargetLabel()}',
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

  Widget _buildStockChangeTypeOptions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final hasEnoughSpace =
            availableWidth >=
            (_minimumButtonAddPurchasedProductWidth * 2 - 32 - 16);
        final buttonSearch = _buildButtonStockChangeType(
          icon: Icons.arrow_drop_down,
          label: 'In',
          enabled: <String>{
            'Purchase',
            'Return',
          }.contains(_selectedTransactionType),
          selected: _selectedStockChangeType == 'in',
          selectedColor: Colors.green,
        );
        final buttonScan = _buildButtonStockChangeType(
          icon: Icons.arrow_drop_up,
          label: 'Out',
          enabled: <String>{
            'Sale',
            'Return',
          }.contains(_selectedTransactionType),
          selected: _selectedStockChangeType == 'out',
          selectedColor: Colors.red,
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

  Widget _buildButtonStockChangeType({
    required IconData icon,
    required String label,
    required bool enabled,
    required bool selected,
    required Color selectedColor,
  }) {
    final foregroundColor =
        enabled
            ? (selected ? selectedColor : ColorsConstants.black)
            : ColorsConstants.black;

    return ElevatedButton(
      onPressed: () {
        if (!enabled) {
          return;
        }

        setState(() {
          _selectedStockChangeType = label.toLowerCase();
        });
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(
          enabled
              ? ColorsConstants.lightGrey
              : ColorsConstants.black.withValues(alpha: 0.3),
        ),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        ),
        minimumSize: WidgetStatePropertyAll(
          Size(_minimumButtonAddPurchasedProductWidth, 0),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: foregroundColor,
              width: selected ? 2 : 1.25,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 50, color: foregroundColor),
          const SizedBox(width: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              color: foregroundColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetDetails() {
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
            '${_getCurrentTargetLabel()} Details',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          _buildTextItem(
            Text(
              '${_getCurrentTargetLabel()} ID',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getCurrentTargetID().toString(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildContaineredTextItem(
            Text(
              'Name',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getCurrentTargetName(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildContaineredTextItem(
            Text(
              'Email',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getCurrentTargetEmail(),
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 6),
          _buildContaineredTextItem(
            Text(
              'Phone Number',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              _getCurrentTargetPhoneNumber(),
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
                'Rp ${_numFormat.format(product.price * product.quantity)}',
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
              key: _purchasedItemKey,
              width: 100,
              child: TextField(
                key: _purchasedItemKey,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  fillColor: ColorsConstants.white,
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(
                  text: product.quantity.toString(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textInputAction: TextInputAction.done,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                ),
                onSubmitted: (value) {
                  product.quantity = int.parse(value == '' ? '0' : value);

                  if (product.quantity > product.currentStock) {
                    product.quantity = product.currentStock;
                  }

                  _computeTotalCost();
                  if (product.quantity <= 0) {
                    _purchasedProducts.remove(product);
                  }

                  setState(() {});
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
}
