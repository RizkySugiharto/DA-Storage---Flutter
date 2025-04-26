import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/account_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/accounts_api.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<AccountRole> _crrntFilters = <AccountRole>{};
  Map<String, Set<String>> _crrntSortings = {};
  List<Account> _accounts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _loadAllAccounts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAllAccounts() async {
    setState(() {
      _isLoading = true;
    });

    _accounts = await AccountsApi.getAllAccounts(
      search: _searchController.text,
      role: _crrntFilters.firstOrNull,
      sortBy:
          (_crrntSortings['Sort By']?.isNotEmpty ?? false)
              ? {
                'Account ID': 'id',
                'Name': 'name',
                'Email': 'email',
                'Role': 'role',
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

  void _onDeletePressed(Account account) async {
    final isSuccess = await AccountsApi.delete(account.id);

    if (!mounted) {
      return;
    }

    if (isSuccess) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Successfully delete the account. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to delete the account.",
        alertType: AlertBannerType.error,
      );
    }
  }

  Future<void> _onRefresh() async {
    await _loadAllAccounts();
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
                            label: 'Accounts Management',
                            actionButtons: [_buildSortIconButton()],
                            canGoBack: true,
                          ),
                          SearchBarWidget(
                            searchController: _searchController,
                            hintText: 'Search account....',
                            onSubmitted: (submitted) {
                              _loadAllAccounts();
                            },
                          ),
                          _buildFilterChips(),
                          _buildAccountList(),
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
                'Sort By': ['Account ID', 'Name', 'Email', 'Role'],
              },
              onSortSelected: (selected, value, crrnt) {
                _crrntSortings = crrnt;
              },
              onDialogClosed: () {
                _loadAllAccounts();
              },
            );
          },
        );
      },
      icon: Icon(Icons.sort_rounded, size: 34, weight: 5),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children:
            ['All', 'Admin', 'Staff'].map((item) {
              final bool isSelected =
                  item == 'All' && _crrntFilters.isEmpty ||
                  item == 'Admin' &&
                      _crrntFilters.contains(AccountRole.admin) ||
                  item == 'Staff' && _crrntFilters.contains(AccountRole.staff);
              final Color color =
                  isSelected ? ColorsConstants.blue : ColorsConstants.black;

              return FilterChip(
                selected: isSelected,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                  side: BorderSide(
                    color: color,
                    width: 1,
                    strokeAlign: BorderSide.strokeAlignCenter,
                  ),
                ),
                backgroundColor: ColorsConstants.white,
                selectedColor: ColorsConstants.blue.withValues(alpha: 0.2),
                label: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: color,
                  ),
                ),
                onSelected: (bool selected) {
                  if (!selected) {
                    return;
                  }

                  _crrntFilters.clear();
                  if (item != 'All') {
                    _crrntFilters.add(
                      {
                            'Admin': AccountRole.admin,
                            'Staff': AccountRole.staff,
                          }[item] ??
                          AccountRole.staff,
                    );
                  }

                  _loadAllAccounts().then((_) {
                    setState(() {});
                  });
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAccountList() {
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
        itemCount: _accounts.length,
        itemBuilder: (context, index) {
          final account = _accounts[index];
          return Column(
            children: [_buildAccountItem(account), const SizedBox(height: 16)],
          );
        },
      );
    }
  }

  Widget _buildAccountItem(Account account) {
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
              Container(
                width: 60,
                height: 60,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: CachedNetworkImage(
                  imageUrl: account.avatarUrl,
                  scale: 0.1,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: account.name,
                            style: GoogleFonts.poppins(fontSize: 16),
                          ),
                          TextSpan(
                            text: ' (${account.getRoleAsString()})',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: ColorsConstants.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      account.email,
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
                    RouteConstants.editAccount,
                    arguments: account,
                  );
                },
                onDeletePressed: () => _onDeletePressed(account),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
