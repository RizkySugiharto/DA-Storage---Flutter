import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/models/category_model.dart';
import 'package:da_storage/data/models/product_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/categories_api.dart';
import 'package:da_storage/data/providers/products_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_select_widget.dart';
import 'package:da_storage/presentation/widgets/input_text_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({super.key});

  @override
  State<EditProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<EditProductScreen> {
  final numFormat = NumberFormat.decimalPattern('ID-id');
  late final _nameController = TextEditingController(text: _product.name);
  late final _priceController = TextEditingController(
    text: numFormat.format(_product.price),
  );
  late final _stockController = TextEditingController(text: '0');
  late String? _selectedCategory = _product.category.name;
  List<Category> _availableCategories = [];
  bool _isLoading = false;

  Product _product = Product.none;

  void _onConfirmPressed(BuildContext context) async {
    if (_nameController.text.isEmpty ||
        (_selectedCategory?.isEmpty ?? false) ||
        _priceController.text.isEmpty ||
        _stockController.text.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "All fields are required to fill",
        alertType: AlertBannerType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newProduct = await ProductsApi.put(
      id: _product.id,
      name: _nameController.text,
      categoryId: _getCategoryByName(_selectedCategory ?? '').id,
      price: int.parse(_priceController.text.replaceAll('.', '')),
      stock: int.parse(_stockController.text.replaceAll('.', '')),
    );

    if (!context.mounted) {
      return;
    }

    if (newProduct != Product.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully edit the product. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to edit the product",
        alertType: AlertBannerType.error,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _fetchProduct(int productId) async {
    _product = await ProductsApi.getSingleProduct(productId);
    setState(() {
      _nameController.text = _product.name;
      _priceController.text = numFormat.format(_product.price);
      _stockController.text = numFormat.format(_product.stock);
      _selectedCategory = _product.category.name;
    });
  }

  void _fetchAllCategories() async {
    _availableCategories = await CategoriesApi.getAllCategories();
    setState(() {});
  }

  Category _getCategoryByName(String name) {
    for (Category category in _availableCategories) {
      if (category.name == name) {
        return category;
      }
    }
    return Category.none;
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final productId = ModalRoute.of(context)!.settings.arguments as int;
      _fetchProduct(productId);
      _fetchAllCategories();
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
                        ScreenLabelWidget(label: 'Edit Product'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Save',
                          cancelLabel: 'Cancel',
                          isLoading: _isLoading,
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
            textController: TextEditingController(text: _product.id.toString()),
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
            options: _availableCategories.map((item) => item.name).toList(),
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
            label: 'Stock',
            textController: _stockController,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000',
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
