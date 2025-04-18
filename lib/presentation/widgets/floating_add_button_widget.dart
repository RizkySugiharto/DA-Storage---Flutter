import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:flutter/material.dart';
import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class FloatingAddButtonWidget extends StatefulWidget {
  const FloatingAddButtonWidget({super.key});

  @override
  State<FloatingAddButtonWidget> createState() =>
      _FloatingAddButtonWidgetState();
}

class _FloatingAddButtonWidgetState extends State<FloatingAddButtonWidget>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController = AnimationController(
    duration: Duration(milliseconds: 250),
    vsync: this,
  );
  late final Animation<double> _scaleAnimation = CurvedAnimation(
    parent: _scaleController,
    curve: Curves.linear,
  );

  void _toggleModal() {
    _scaleController.animateTo(
      _scaleController.value == 0 ? 1 : 0,
      duration: _scaleController.duration,
      curve: Curves.easeIn,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 26,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ScaleTransition(
            alignment: Alignment.bottomCenter,
            scale: _scaleAnimation,
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: ColorsConstants.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: ColorsConstants.black.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                clipBehavior: Clip.hardEdge,
                borderRadius: BorderRadius.circular(16),
                color: Colors.transparent,
                child: Column(
                  children: [
                    _buildAddItem(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteConstants.createTransaction,
                        );
                      },
                      icon: Icons.shopping_cart,
                      label: 'Create Transaction',
                    ),
                    _buildAddItem(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteConstants.addProduct);
                      },
                      icon: Icons.inventory_2,
                      label: 'Add Product',
                    ),
                    _buildAddItem(
                      onPressed: () {
                        Navigator.pushNamed(context, RouteConstants.addAccount);
                      },
                      icon: Icons.account_box,
                      label: 'Add Account',
                    ),
                    _buildAddItem(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          RouteConstants.addCategory,
                        );
                      },
                      icon: Icons.category,
                      label: 'Add Category',
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 75,
            height: 75,
            child: FloatingActionButton(
              onPressed: _toggleModal,
              splashColor: ColorsConstants.white.withValues(alpha: 0.2),
              backgroundColor: ColorsConstants.blue,
              shape: const CircleBorder(),
              child: const Icon(
                Icons.add,
                color: ColorsConstants.white,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddItem({
    required void Function() onPressed,
    required IconData icon,
    required String label,
  }) {
    return InkWell(
      onTap: () {
        _toggleModal();
        onPressed();
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 25, color: ColorsConstants.black),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ColorsConstants.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
