import 'package:cached_network_image/cached_network_image.dart';
import 'package:da_cashier/data/constants/app_constants.dart';
import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/presentation/utils/barcode_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final String username;
  final String avatarUrl;
  final bool showScanner;

  const HeaderWidget({
    super.key,
    required this.username,
    required this.avatarUrl,
    this.showScanner = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            color: ColorsConstants.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            child: CachedNetworkImage(imageUrl: avatarUrl),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppConstants.appName,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Welcome back, ${username.split(' ')[0]}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: ColorsConstants.grey,
                ),
              ),
            ],
          ),
          const Spacer(),
          showScanner
              ? IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () {
                  BarcodeUtils.scanBarcode(context, createTransaction: true);
                },
                iconSize: 30,
              )
              : const SizedBox(),
        ],
      ),
    );
  }
}
