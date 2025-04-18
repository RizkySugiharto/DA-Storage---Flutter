import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
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

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
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
                          onSubmitted: (submitted) {},
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
                'Sort Order': {
                  'Ascending': SortOrderEnum.ascending,
                  'Descending': SortOrderEnum.descending,
                },
                'Sort By': {
                  'Product ID': SortByEnum.productId,
                  'Name': SortByEnum.name,
                  'Price': SortByEnum.price,
                  'Stock': SortByEnum.stock,
                  'Updated Date': SortByEnum.updatedDate,
                },
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
