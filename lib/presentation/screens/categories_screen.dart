import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/category_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/categories_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/more_button_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<CategoriesScreen> {
  final TextEditingController _searchController = TextEditingController();
  Map<String, Set<String>> _crrntSortings = {};
  List<Category> _categories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCategories() async {
    setState(() {
      isLoading = true;
    });

    _categories = await CategoriesApi.getAllCategories(
      search: _searchController.text,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Category ID': 'id',
                'Name': 'name',
                'Description': 'description',
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
      isLoading = false;
    });
  }

  void _onDeletePressed(Category category) async {
    final isSuccess = await CategoriesApi.delete(category.id);

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      AlertBannerUtils.showAlertBanner(
        context,
        message:
            "Successfully delete the category. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to delete the category.",
        alertType: AlertBannerType.success,
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllCategories();
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
                            label: 'Categories Management',
                            actionButtons: [_buildSortIconButton()],
                            canGoBack: true,
                          ),
                          SearchBarWidget(
                            searchController: _searchController,
                            hintText: 'Search category....',
                            onSubmitted: (submitted) {
                              _loadAllCategories();
                            },
                          ),
                          _buildCategoryList(),
                        ],
                      ),
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
              currentSortings:
                  _crrntSortings.isNotEmpty ? _crrntSortings : null,
              sortSections: {
                'Sort Order': ['Ascending', 'Descending'],
                'Sort By': ['Category ID', 'Name', 'Description'],
              },
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadAllCategories();
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildCategoryList() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Column(
            children: [
              _buildCategoryItem(category),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }
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
                    arguments: category,
                  );
                },
                onDeletePressed: () => _onDeletePressed(category),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
