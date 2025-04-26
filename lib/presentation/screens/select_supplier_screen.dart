import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/providers/suppliers_api.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:da_storage/presentation/widgets/supplier_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SelectSupplierScreen extends StatefulWidget {
  const SelectSupplierScreen({super.key});

  @override
  State<SelectSupplierScreen> createState() => _SelectSupplierScreenState();
}

class _SelectSupplierScreenState extends State<SelectSupplierScreen> {
  final TextEditingController _searchController = TextEditingController();
  Supplier _selected = Supplier.none;
  List<Supplier> _suppliers = [];
  bool _isLoading = true;
  Map<String, Set<String>> _crrntSortings = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllSuppliers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllSuppliers() async {
    setState(() {
      _isLoading = true;
    });

    _suppliers = await SuppliersApi.getAllSuppliers(
      search: _searchController.text,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Supplier ID': 'id',
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
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadAllSuppliers();
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
                            label: 'Select Suppliers',
                            actionButtons: [_buildSortIconButton()],
                            canGoBack: true,
                          ),
                          SearchBarWidget(
                            searchController: _searchController,
                            hintText: 'Search supplier....',
                            onSubmitted: (submitted) {},
                          ),
                          _isLoading
                              ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : _buildSupplierList(),
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
                'Sort By': ['Supplier ID', 'Name', 'Email', 'Phone Number'],
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
    if (_isLoading) {
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
              SupplierCardWidget(
                supplier: _suppliers[index],
                onTap: () {
                  _selected = _suppliers[index];
                  Navigator.pop(context, _selected);
                },
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }
  }
}
