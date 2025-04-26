import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/models/category_model.dart';
import 'package:da_storage/data/models/product_model.dart';
import 'package:da_storage/data/providers/categories_api.dart';
import 'package:da_storage/data/providers/products_api.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/filters_dialog_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/product_list_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class SelectProductsScreen extends StatefulWidget {
  const SelectProductsScreen({super.key});

  @override
  State<SelectProductsScreen> createState() => _SelectProductsScreenState();
}

class _SelectProductsScreenState extends State<SelectProductsScreen> {
  final Set<Product> _selectedProducts = <Product>{};
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
  bool _isLoading = true;
  Map<String, Set<String>> _crrntFilters = {};
  Map<String, Set<String>> _crrntSortings = {};
  List<Category> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllProducts();
      _fetchAllCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllProducts() async {
    setState(() {
      _isLoading = true;
    });

    _products = await ProductsApi.getAllProducts(
      search: _searchController.text,
      filterStockLevel:
          _crrntFilters['Stock Level']
              ?.map((item) => item.toLowerCase())
              .toList(),
      filterCategoryId:
          _crrntFilters['Category']
              ?.map((item) => _getCategoryByName(item).id)
              .toList(),
      filterUpdatedDate:
          (_crrntFilters['Updated Date']?.isNotEmpty ?? false)
              ? _crrntFilters['Updated Date']?.first.toLowerCase()
              : '',
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Product ID': 'id',
                'Name': 'name',
                'Price': 'price',
                'Stock': 'stock',
                'Updated Date': 'updated_at',
              }[_crrntSortings['Sort By']?.first]
              : '',
      sortOrder:
          (_crrntSortings['Sort Order']?.isNotEmpty ?? false)
              ? {
                'Ascending': 'asc',
                'Descending': 'desc',
              }[_crrntSortings['Sort Order']?.first]
              : '',
    );

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _fetchAllCategories() async {
    setState(() {
      _isLoading = true;
    });

    _availableCategories = await CategoriesApi.getAllCategories();

    setState(() {
      _isLoading = false;
    });
  }

  Category _getCategoryByName(String name) {
    for (Category category in _availableCategories) {
      if (category.name == name) {
        return category;
      }
    }
    return Category.none;
  }

  void _onConfirmPressed() {
    Navigator.pop(context, _selectedProducts);
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  Future<void> _onRefresh() async {
    await _loadAllProducts();
    await _fetchAllCategories();
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
                      physics: AlwaysScrollableScrollPhysics(),
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
                          _isLoading
                              ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : ProductListWidget(
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
              currentFilters: _crrntFilters.isNotEmpty ? _crrntFilters : null,
              filterSections: {
                'Stock Level': FilterDialogSectionData(
                  filterList: ['Normal', 'Low', 'Empty'],
                  isChoice: false,
                ),
                'Category': FilterDialogSectionData(
                  filterList:
                      _availableCategories.map((item) => item.name).toList(),
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
              onFilterSelected: (selected, value, crrnt) {
                _crrntFilters = crrnt;
              },
              onDialogClosed: () {
                _loadAllProducts();
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
              currentSortings:
                  _crrntSortings.isNotEmpty ? _crrntSortings : null,
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
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadAllProducts();
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
