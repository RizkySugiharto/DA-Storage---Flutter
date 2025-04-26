import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/customers_api.dart';
import 'package:da_storage/data/static/account_static.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/more_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomerCardWidget extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCardWidget({super.key, required this.customer, this.onTap});

  void _onDeletePressed(BuildContext context, Customer customer) async {
    final isSuccess = await CustomersApi.delete(customer.id);

    if (!context.mounted) {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
              AccountStatic.isAdmin()
                  ? MoreButtonWidget(
                    onEditPressed: () {
                      Navigator.pushNamed(
                        context,
                        RouteConstants.editCustomer,
                        arguments: customer,
                      );
                    },
                    onDeletePressed: () => _onDeletePressed(context, customer),
                  )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
