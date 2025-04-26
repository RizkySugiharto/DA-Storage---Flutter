import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/providers/customers_api.dart';
import 'package:da_storage/presentation/widgets/customer_card_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class SelectCustomerScreen extends StatefulWidget {
  const SelectCustomerScreen({super.key});

  @override
  State<SelectCustomerScreen> createState() => _SelectCustomerScreenState();
}

class _SelectCustomerScreenState extends State<SelectCustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  Customer _selected = Customer.none;
  List<Customer> _customers = [];
  bool _isLoading = true;
  Map<String, Set<String>> _crrntSortings = {};

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllCustomers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCustomers() async {
    setState(() {
      _isLoading = true;
    });

    _customers = await CustomersApi.getAllCustomers(
      search: _searchController.text,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Customer ID': 'id',
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
    await _loadAllCustomers();
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
                            label: 'Select Customers',
                            actionButtons: [_buildSortIconButton()],
                            canGoBack: true,
                          ),
                          SearchBarWidget(
                            searchController: _searchController,
                            hintText: 'Search customer....',
                            onSubmitted: (submitted) {},
                          ),
                          _isLoading
                              ? Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                              : _buildCustomerList(),
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
                'Sort By': ['Customer ID', 'Name', 'Email', 'Phone Number'],
              },
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadAllCustomers();
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildCustomerList() {
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
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              CustomerCardWidget(
                customer: _customers[index],
                onTap: () {
                  _selected = _customers[index];
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
