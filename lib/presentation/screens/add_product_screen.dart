import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/data/providers/categories_api.dart';
import 'package:da_cashier/data/providers/products_api.dart';
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

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedCategory;
  List<Category> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fetchAllCategories();
    });
  }

  void _onConfirmPressed(BuildContext context) {
    ProductsApi.post(
      name: _nameController.text,
      categoryId: _getCategoryByName(_selectedCategory ?? '').id,
      price: int.parse(_priceController.text.replaceAll('.', '')),
      stock: int.parse(_stockController.text.replaceAll('.', '')),
    );
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Successfully add the product",
      alertType: AlertBannerType.success,
    );
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  Category _getCategoryByName(String name) {
    for (Category category in _availableCategories) {
      if (category.name == name) {
        return category;
      }
    }
    return Category.none;
  }

  void _fetchAllCategories() async {
    _availableCategories = await CategoriesApi.getAllCategories();
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
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Add Product'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Add',
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
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Product's name",
          ),
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
          InputTextWidget(
            label: 'Price',
            textController: _priceController,
            enablePriceLabel: true,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000.000',
          ),
          InputTextWidget(
            label: 'Stock',
            textController: _stockController,
            enablePriceFormat: true,
            keyboardType: TextInputType.number,
            hint: '100.000',
          ),
        ],
      ),
    );
  }
}
