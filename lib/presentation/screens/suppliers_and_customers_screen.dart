import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/presentation/tabs/customers_tab.dart';
import 'package:da_storage/presentation/tabs/suppliers_tab.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SuppliersAndCustomersScreen extends StatefulWidget {
  const SuppliersAndCustomersScreen({super.key});

  @override
  State<SuppliersAndCustomersScreen> createState() =>
      _SuppliersAndCustomersScreenState();
}

class _SuppliersAndCustomersScreenState
    extends State<SuppliersAndCustomersScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
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
                HeaderWidget(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: ColorsConstants.lightGrey,
                        child: TabBar(
                          indicatorWeight: 3,
                          padding: const EdgeInsets.only(top: 16),
                          controller: _tabController,
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          tabs: [
                            Tab(text: 'Suppliers'),
                            Tab(text: 'Customers'),
                          ],
                        ),
                      ),
                      Flexible(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SuppliersTab(controller: _tabController),
                            CustomersTab(controller: _tabController),
                          ],
                        ),
                      ),
                    ],
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
}
