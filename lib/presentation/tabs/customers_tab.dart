import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/customers_api.dart';
import 'package:da_storage/data/providers/suppliers_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/more_button_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:da_storage/presentation/widgets/search_bar_widget.dart';
import 'package:da_storage/presentation/widgets/sorts_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomersTab extends StatefulWidget {
  final TabController controller;

  const CustomersTab({super.key, required this.controller});

  @override
  State<CustomersTab> createState() => _CustomersTabState();
}

class _CustomersTabState extends State<CustomersTab> {
  late final TextEditingController _searchController = TextEditingController(
    text: _searchQuery,
  );
  static String _searchQuery = '';
  static Map<String, Set<String>> _crrntSortings = {};
  static List<Customer> _customers = [];
  static bool isLoading = true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _searchController.addListener(() {
        _searchQuery = _searchController.text;
      });

      if (_customers.isEmpty) {
        _loadAllCustomers();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllCustomers() async {
    setState(() {
      isLoading = true;
    });

    _customers = await CustomersApi.getAllCustomers(
      search: _searchController.text,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Customers ID': 'id',
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

  void _onDeletePressed(Customer customer) async {
    final isSuccess = await SuppliersApi.delete(customer.id);

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      AlertBannerUtils.showAlertBanner(
        context,
        message:
            "Successfully delete the customer. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to delete the customer.",
        alertType: AlertBannerType.success,
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllCustomers();
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
              label: 'Customers Management',
              actionButtons: [_buildSortIconButton()],
              canGoBack: true,
            ),
            SearchBarWidget(
              searchController: _searchController,
              hintText: 'Search customer....',
              onSubmitted: (submitted) {
                _loadAllCustomers();
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
                'Sort By': ['Customers ID', 'Name', 'Email', 'Phone Number'],
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
        itemCount: _customers.length,
        itemBuilder: (context, index) {
          final customer = _customers[index];
          return Column(
            children: [
              _buildSupplierItem(customer),
              const SizedBox(height: 16),
            ],
          );
        },
      );
    }
  }

  Widget _buildSupplierItem(Customer customer) {
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
                      customer.name,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                    Text(
                      customer.email,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: ColorsConstants.grey,
                      ),
                    ),
                    Text(
                      customer.phoneNumber,
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
                    RouteConstants.editCustomer,
                    arguments: customer,
                  );
                },
                onDeletePressed: () => _onDeletePressed(customer),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
