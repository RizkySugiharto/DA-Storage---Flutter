import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_cashier/presentation/widgets/filters_dialog_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/product_list_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:da_cashier/presentation/widgets/search_bar_widget.dart';
import 'package:da_cashier/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({super.key});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<Product> _selectedProducts = <Product>{};
  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Coffe Cup',
      category: Category(
        id: 1,
        name: 'Groceries & Food Items',
        description: '',
      ),
      price: 5000,
      stock: 50,
      lastUpdated: DateTime(2025, 3, 21),
    ),
    Product(
      id: 2,
      name: 'Fried Rice',
      category: Category(
        id: 1,
        name: 'Groceries & Food Items',
        description: '',
      ),
      price: 12000,
      stock: 5,
      lastUpdated: DateTime(2025, 3, 21),
    ),
    Product(
      id: 3,
      name: 'Egg',
      category: Category(
        id: 1,
        name: 'Groceries & Food Items',
        description: '',
      ),
      price: 3000,
      stock: 320,
      lastUpdated: DateTime(2025, 3, 21),
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onConfirmPressed() {
    Navigator.pop(context, _selectedProducts);
  }

  void _onCancelPressed() {
    Navigator.pop(context);
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
                        ScreenLabelWidget(
                          label: 'Select Products',
                          actionButtons: [
                            _buildFilterIconButton(),
                            _buildSortIconButton(),
                          ],
                        ),
                        SearchBarWidget(
                          searchController: _searchController,
                          hintText: 'Search items....',
                          onSubmitted: (submitted) {},
                        ),
                        ProductListWidget(
                          products: _products,
                          isSelectable: true,
                          onChanged: (selectedProducts) {
                            setState(() {
                              _selectedProducts.clear();
                              _selectedProducts.addAll(selectedProducts);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(),
                NavbarWidget(),
              ],
            ),
            FloatingAddButtonWidget(),
          ],
        ),
      ),
    );
  }

  IconButton _buildFilterIconButton() {
    return IconButton(
      onPressed: () {
        showDialog(
          useSafeArea: true,
          context: context,
          builder: (BuildContext dialogContext) {
            return FiltersDialogWidget(
              dialogContext: dialogContext,
              title: 'Filters',
              filterSections: {
                'Stock Level': FilterDialogSectionData(
                  filterList: ['Normal', 'Low', 'Empty'],
                  isChoice: false,
                ),
                'Updated Date': FilterDialogSectionData(
                  filterList: [
                    'Today',
                    '1 Week',
                    '1 Month',
                    '3 Months',
                    '6 Months',
                    '1 Year',
                    '2 Years',
                    '3 Years',
                  ],
                  isChoice: true,
                ),
              },
            );
          },
        );
      },
      icon: Icon(Icons.filter_alt_outlined, size: 34, weight: 5),
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
              sortSections: {
                'Sort Order': ['Ascending', 'Descending'],
                'Sort By': [
                  'Product ID',
                  'Name',
                  'Price',
                  'Stock',
                  'Updated Date',
                ],
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.only(top: 16, bottom: 30),
      decoration: BoxDecoration(
        color: ColorsConstants.lightGrey,
        boxShadow: [
          BoxShadow(
            color: ColorsConstants.black.withValues(alpha: 0.25),
            offset: const Offset(0, -4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Selected:  ${_selectedProducts.length}',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ConfirmationButtonsWidget(
            confirmLabel: 'Add',
            cancelLabel: 'Cancel',
            onConfirmPressed: _onConfirmPressed,
            onCancelPressed: _onCancelPressed,
          ),
        ],
      ),
    );
  }
}

enum FilterStockLevelEnum { low, empty, normal }

enum FilterUpdatedDateEnum {
  today,
  week1,
  month1,
  months3,
  months6,
  year1,
  years2,
  years3,
}

enum SortOrderEnum { ascending, descending }

enum SortByEnum { productId, name, price, stock, updatedDate }
