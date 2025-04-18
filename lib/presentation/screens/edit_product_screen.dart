import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/input_select_widget.dart';
import 'package:da_cashier/presentation/widgets/input_text_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<EditProductScreen> {
  final numFormat = NumberFormat.decimalPattern('ID-id');
  late final _nameController = TextEditingController(text: product.name);
  late final _priceController = TextEditingController(
    text: numFormat.format(product.price),
  );
  late final _addedStockController = TextEditingController(text: '0');
  late final _newStockController = TextEditingController(
    text: numFormat.format(product.stock),
  );
  late String? _selectedCategory = product.category.name;
  int _recommendedNewStock = 5;

  final product = Product(
    id: 1,
    name: 'Coffe Cup',
    category: Category(id: 1, name: 'Groceries & Food Items', description: ''),
    price: 5000,
    stock: 50,
    lastUpdated: DateTime(2025, 3, 21),
  );

  void _onConfirmPressed(BuildContext context) {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Successfully edit the product",
      alertType: AlertBannerType.success,
    );
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _fetchProduct(int productId) {}

  void _fetchRecommendedNewStock(int productId) {}

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final productId = ModalRoute.of(context)!.settings.arguments as int;
      _fetchProduct(productId);
      _fetchRecommendedNewStock(productId);
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
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Edit Product'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Save',
                          cancelLabel: 'Cancel',
                          onConfirmPressed: () => _onConfirmPressed(context),
                          onCancelPressed: () => _onCancelPressed(context),
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

  Widget _buildFormBox() {
    return Container(
      margin: const EdgeInsets.all(16),
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
          InputTextWidget(
            label: 'Product ID',
            textController: TextEditingController(text: product.id.toString()),
            readOnly: true,
            hint: "Product's ID",
          ),
          const SizedBox(height: 24),
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Product's name",
          ),
          const SizedBox(height: 24),
          InputSelectWidget(
            label: 'Category',
            options: ['a', 'b', 'Groceries & Food Items'],
            hint: 'Choose one category',
            value: _selectedCategory,
            onChanged: (selected) {
              setState(() {
                _selectedCategory = selected;
              });
            },
          ),
          const SizedBox(height: 24),
          InputTextWidget(
            label: 'Price',
            textController: _priceController,
            enablePriceLabel: true,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000.000',
          ),
          const SizedBox(height: 24),
          InputTextWidget(
            label: 'Added Stock',
            textController: _addedStockController,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000',
            onChanged: (value) {
              if (value == null || value.isEmpty) return;

              final newStock =
                  product.stock + int.parse(value.replaceAll('.', ''));
              _newStockController.value = TextEditingValue(
                text: numFormat.format(newStock),
              );
            },
          ),
          const SizedBox(height: 24),
          InputTextWidget(
            label: 'New Stock',
            textController: _newStockController,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000',
            onChanged: (value) {
              if (value == null || value.isEmpty) return;

              final addedStock =
                  int.parse(value.replaceAll('.', '')) - product.stock;
              _addedStockController.value = TextEditingValue(
                text: numFormat.format(addedStock),
              );
            },
          ),
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(
              text: 'Recommended New Stock:  ',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: _recommendedNewStock.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
