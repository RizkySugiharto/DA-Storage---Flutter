import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:da_cashier/data/notifiers/navbar_notifiers.dart';

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      padding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
      color: ColorsConstants.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            context,
            icon: Icons.home,
            label: 'Home',
            navIndex: 0,
            routeName: RouteConstants.home,
          ),
          _buildNavItem(
            context,
            icon: Icons.inventory_2,
            label: 'Produts',
            navIndex: 1,
            routeName: RouteConstants.products,
          ),
          const SizedBox(width: 90),
          _buildNavItem(
            context,
            icon: Icons.history,
            label: 'History',
            navIndex: 2,
            routeName: RouteConstants.history,
          ),
          _buildNavItem(
            context,
            icon: Icons.settings,
            label: 'Settings',
            navIndex: 3,
            routeName: RouteConstants.settings,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int navIndex,
    required String routeName,
  }) {
    final bool isSelected = navIndexNotifier.value == navIndex;

    return Expanded(
      child: InkWell(
        onTap: () {
          navIndexNotifier.value = navIndex;
          Navigator.pushNamedAndRemoveUntil(
            context,
            routeName,
            ModalRoute.withName('/'),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? ColorsConstants.blue : ColorsConstants.black,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: isSelected ? ColorsConstants.blue : ColorsConstants.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
