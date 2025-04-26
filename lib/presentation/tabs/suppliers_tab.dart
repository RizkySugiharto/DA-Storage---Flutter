import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/providers/suppliers_api.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:da_storage/presentation/widgets/supplier_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SuppliersTab extends StatefulWidget {
  final TabController controller;

  const SuppliersTab({super.key, required this.controller});

  @override
  State<SuppliersTab> createState() => _SuppliersTabState();
}

class _SuppliersTabState extends State<SuppliersTab> {
  late final TextEditingController _searchController = TextEditingController(
    text: _searchQuery,
  );
  static String _searchQuery = '';
  static Map<String, Set<String>> _crrntSortings = {};
  static List<Supplier> _suppliers = [];
  static bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _searchController.addListener(() {
        _searchQuery = _searchController.text;
      });

      if (_suppliers.isEmpty) {
        _loadAllSuppliers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSuppliers() async {
    setState(() {
      isLoading = true;
    });

    _suppliers = await SuppliersApi.getAllSuppliers(
      search: _searchController.text,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Suppliers ID': 'id',
                'Name': 'name',
                'Email': 'email',
                'Phone Number': 'phone_number',
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

  Future<void> _onRefresh() async {
    await _loadAllSuppliers();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ScreenLabelWidget(
              label: 'Suppliers Management',
              actionButtons: [_buildSortIconButton()],
              canGoBack: true,
            ),
            SearchBarWidget(
              searchController: _searchController,
              hintText: 'Search supplier....',
              onSubmitted: (submitted) {
                _loadAllSuppliers();
              },
            ),
            _buildSupplierList(),
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
                'Sort By': ['Suppliers ID', 'Name', 'Email', 'Phone Number'],
              },
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadAllSuppliers();
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildSupplierList() {
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
        itemCount: _suppliers.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              SupplierCardWidget(supplier: _suppliers[index]),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }
  }
}
