import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/models/account_model.dart';
import 'package:da_cashier/data/models/product_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/data/providers/products_api.dart';
import 'package:da_cashier/data/static/account_static.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/widgets/more_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ProductListWidget extends StatefulWidget {
  final List<Product> products;
  final bool isSelectable;
  final void Function(Set<Product>)? onChanged;

  const ProductListWidget({
    super.key,
    required this.products,
    this.isSelectable = false,
    this.onChanged,
  });

  @override
  State<ProductListWidget> createState() => _ProductListWidgetState();
}

class _ProductListWidgetState extends State<ProductListWidget> {
  late final _selectedProducts = <Product>{};

  void _onDeletePressed(int productId) async {
    final isSuccess = await ProductsApi.delete(productId);

    if (isSuccess) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Successfully delete the product. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to delete the product",
        alertType: AlertBannerType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.products.isEmpty) {
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
        itemCount: widget.products.length,
        itemBuilder: (context, index) {
          final product = widget.products[index];
          return Column(
            children: [_buildProductItem(product), const SizedBox(height: 16)],
          );
        },
      );
    }
  }

  Widget _buildProductItem(Product product) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final numFormat = NumberFormat.decimalPattern('ID-id');
    final stockLevelColor = product.getStockLevelColor();
    final isSelected = _selectedProducts.contains(product);

    return InkWell(
      onTap: () {
        if (!widget.isSelectable) return;

        setState(() {
          isSelected
              ? _selectedProducts.remove(product)
              : _selectedProducts.add(product);

          if (widget.onChanged != null) {
            widget.onChanged!(_selectedProducts);
          }
        });
      },
      splashColor: ColorsConstants.blue.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(6),
      child: Ink(
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(6),
          border:
              widget.isSelectable && isSelected
                  ? Border.all(width: 2, color: ColorsConstants.blue)
                  : Border.all(width: 2, color: ColorsConstants.white),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ColorsConstants.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        product.category.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ColorsConstants.grey,
                        ),
                      ),
                      Text(
                        'Rp ${numFormat.format(product.price)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: ColorsConstants.blue,
                        ),
                      ),
                    ],
                  ),
                  AccountStatic.isAdmin() && !widget.isSelectable
                      ? MoreButtonWidget(
                        enableBarcodeOptions: true,
                        onEditPressed: () {
                          Navigator.pushNamed(
                            context,
                            RouteConstants.editProduct,
                            arguments: product.id,
                          );
                        },
                        onDeletePressed: () => _onDeletePressed(product.id),
                      )
                      : const SizedBox(),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Stock: ${product.stock}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: stockLevelColor,
                    ),
                  ),
                  Text(
                    'Updated: ${dateFormat.format(product.lastUpdated)}',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: ColorsConstants.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
