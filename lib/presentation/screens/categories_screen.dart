import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/category_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/more_button_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:da_cashier/presentation/widgets/search_bar_widget.dart';
import 'package:da_cashier/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  final List<Category> _accounts = [
    Category(
      id: 1,
      name: 'Electronics',
      description:
          'Mobile devices, computers, audio equipment, accessories, etc.',
    ),
    Category(
      id: 1,
      name: 'Electronics',
      description:
          'Mobile devices, computers, audio equipment, accessories, etc.',
    ),
    Category(
      id: 1,
      name: 'Electronics',
      description:
          'Mobile devices, computers, audio equipment, accessories, etc.',
    ),
  ];

  CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();

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
                          label: 'Categories Management',
                          actionButtons: [_buildSortIconButton()],
                          canGoBack: true,
                        ),
                        SearchBarWidget(
                          searchController: _searchController,
                          hintText: 'Search category....',
                          onSubmitted: (submitted) {},
                        ),
                        _buildCategoryList(),
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
                'Sort By': ['Category ID', 'Name', 'Description'],
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget._accounts.length,
      itemBuilder: (context, index) {
        final category = widget._accounts[index];
        return Column(
          children: [_buildCategoryItem(category), const SizedBox(height: 16)],
        );
      },
    );
  }

  Widget _buildCategoryItem(Category category) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(6),
      child: Ink(
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: ColorsConstants.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      category.name,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    Text(
                      category.description,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorsConstants.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              MoreButtonWidget(
                onEditPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteConstants.editCategory,
                    arguments: category.id,
                  );
                },
                onDeletePressed: () {
                  AlertBannerUtils.showAlertBanner(
                    context,
                    message: "Successfully delete the category",
                    alertType: AlertBannerType.success,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum SortOrderEnum { ascending, descending }

enum SortByEnum { categoryId, name, description }
