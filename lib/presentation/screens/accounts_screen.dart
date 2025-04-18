import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/account_model.dart';
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
import 'package:cached_network_image/cached_network_image.dart';

class AccountsScreen extends StatefulWidget {
  final List<Account> _accounts = [
    Account(
      id: 1,
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNt9UpcsobJNOGFHPeBt-88iRmqjflBnIjhw&s',
      name: 'Udin Surudin',
      email: 'udinsurudin12345@gmail.com',
      role: AccountRole.administrator,
    ),
    Account(
      id: 1,
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNt9UpcsobJNOGFHPeBt-88iRmqjflBnIjhw&s',
      name: 'Udin Surudin',
      email: 'udinsurudin12345@gmail.com',
      role: AccountRole.administrator,
    ),
    Account(
      id: 1,
      avatarUrl:
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNt9UpcsobJNOGFHPeBt-88iRmqjflBnIjhw&s',
      name: 'Udin Surudin',
      email: 'udinsurudin12345@gmail.com',
      role: AccountRole.administrator,
    ),
  ];

  AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<FilterEnum> _crrntFilters = <FilterEnum>{FilterEnum.all};

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
                          label: 'Accounts Management',
                          actionButtons: [_buildSortIconButton()],
                          canGoBack: true,
                        ),
                        SearchBarWidget(
                          searchController: _searchController,
                          hintText: 'Search account....',
                          onSubmitted: (submitted) {},
                        ),
                        _buildFilterChips(),
                        _buildAccountList(),
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
                'Sort Order': {
                  'Ascending': SortOrderEnum.ascending,
                  'Descending': SortOrderEnum.descending,
                },
                'Sort By': {
                  'Account ID': SortByEnum.accountId,
                  'Name': SortByEnum.name,
                  'Email': SortByEnum.email,
                  'Role': SortByEnum.role,
                },
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
            {
              'All': FilterEnum.all,
              'Administrator': FilterEnum.administrator,
              'Cashier': FilterEnum.cashier,
            }.entries.map((entry) {
              final bool isSelected = _crrntFilters.contains(entry.value);
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
                  entry.key,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: color,
                  ),
                ),
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _crrntFilters.clear();
                      _crrntFilters.add(entry.value);
                    }
                  });
                },
              );
            }).toList(),
      ),
    );
  }

  Widget _buildAccountList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      itemCount: widget._accounts.length,
      itemBuilder: (context, index) {
        final account = widget._accounts[index];
        return Column(
          children: [_buildAccountItem(account), const SizedBox(height: 16)],
        );
      },
    );
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
              CircleAvatar(
                radius: 30,
                child: CachedNetworkImage(imageUrl: account.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      account.name,
                      style: GoogleFonts.poppins(fontSize: 16),
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
                    arguments: account.id,
                  );
                },
                onDeletePressed: () {
                  AlertBannerUtils.showAlertBanner(
                    context,
                    message: "Successfully delete the account",
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

enum SortByEnum { accountId, name, email, role }

enum FilterEnum { all, administrator, cashier }
