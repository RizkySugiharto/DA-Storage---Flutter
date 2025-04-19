import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/data/providers/categories_api.dart';
import 'package:da_cashier/data/providers/products_api.dart';
import 'package:da_cashier/presentation/widgets/filters_dialog_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/product_list_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:da_cashier/presentation/widgets/search_bar_widget.dart';
import 'package:da_cashier/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Product> _products = [];
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

  void _loadAllProducts() async {
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
    setState(() {});
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
                          label: 'All Products',
                          actionButtons: [
                            _buildFilterIconButton(),
                            _buildSortIconButton(),
                          ],
                        ),
                        SearchBarWidget(
                          searchController: _searchController,
                          hintText: 'Search items....',
                          onSubmitted: (submitted) {
                            _loadAllProducts();
                          },
                        ),
                        ProductListWidget(products: _products),
                        _buildStockLegends(),
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

  Widget _buildStockLegends() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 42,
          left: 16,
          right: 16,
          top: 32,
        ),
        child: Wrap(
          spacing: 16,
          runSpacing: 10,
          alignment: WrapAlignment.spaceAround,
          children: [
            _buildStockLegendItem(
              color: const Color(0xFF6B7280),
              label: 'Normal',
            ),
            _buildStockLegendItem(color: const Color(0xFFEA4335), label: 'Low'),
            _buildStockLegendItem(
              color: const Color(0xFF5E1F1F),
              label: 'Empty',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockLegendItem({required Color color, required String label}) {
    const double circleSize = 15;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }
}

enum SortOrderEnum { ascending, descending }

enum SortByEnum { productId, name, price, stock, updatedDate }
