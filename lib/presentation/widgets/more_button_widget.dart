import 'dart:typed_data';

import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/static/account_static.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/utils/barcode_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';

class MoreButtonWidget extends StatelessWidget {
  final double spacing = 16;
  final void Function()? onEditPressed;
  final void Function()? onDeletePressed;
  final bool enableBarcodeOptions;
  final String barcodeValue;

  const MoreButtonWidget({
    super.key,
    this.onEditPressed,
    this.onDeletePressed,
    this.enableBarcodeOptions = false,
    this.barcodeValue = '',
  });

  Future<void> _onDisplayBarcode(
    BuildContext context,
    BuildContext dialogContext,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext displayContext) {
        return AlertDialog(
          backgroundColor: ColorsConstants.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Barcode',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: ColorsConstants.black,
              fontSize: 18,
            ),
          ),
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: ColorsConstants.white,
            child: BarcodeUtils.generateBarcode(barcodeValue),
          ),
        );
      },
    );
  }

  Future<void> _onSaveAndShare(
    BuildContext context,
    BuildContext dialogContext,
  ) async {
    final params = ShareParams(
      title: 'Barocode File',
      files: [XFile.fromData(barcodeToBytes())],
      fileNameOverrides: ['$barcodeValue.png'],
    );
    final result = await SharePlus.instance.share(params);

    if (!context.mounted || !dialogContext.mounted) {
      return;
    }

    if (result.status == ShareResultStatus.success) {
      Navigator.of(dialogContext).pop();
      AlertBannerUtils.showAlertBanner(
        context,
        message: 'Successfully share the barcode as file.',
        alertType: AlertBannerType.success,
      );
    }
  }

  Uint8List barcodeToBytes() {
    final image = img.Image(width: 400, height: 160);

    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    drawBarcode(
      image,
      Barcode.upcE(),
      barcodeValue,
      width: 400,
      height: 160,
      font: img.arial24,
    );

    return img.encodePng(image);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MoreButtonEnum>(
      menuPadding: const EdgeInsets.all(0),
      color: ColorsConstants.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 10,
      onSelected: (MoreButtonEnum value) {
        switch (value) {
          case MoreButtonEnum.barcode:
            showDialog(
              context: context,
              builder: (dialogContext) {
                return _buildBarcodeOptionsDialog(context, dialogContext);
              },
            );
          case MoreButtonEnum.edit:
            onEditPressed!();
          case MoreButtonEnum.delete:
            onDeletePressed!();
        }
      },
      itemBuilder: (BuildContext context) {
        final menuItems = <PopupMenuEntry<MoreButtonEnum>>[];

        if (enableBarcodeOptions) {
          menuItems.add(
            PopupMenuItem(
              padding: EdgeInsets.all(spacing),
              value: MoreButtonEnum.barcode,
              child: _buildMenuItem(
                iconData: Icons.qr_code,
                label: 'Barcode',
                color: Colors.black,
              ),
            ),
          );
        }

        if (AccountStatic.isAdmin()) {
          menuItems.addAll([
            PopupMenuItem(
              padding: EdgeInsets.all(spacing),
              value: MoreButtonEnum.edit,
              child: _buildMenuItem(
                iconData: Icons.edit_square,
                label: 'Edit',
                color: Colors.black,
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.all(spacing),
              value: MoreButtonEnum.delete,
              child: _buildMenuItem(
                iconData: Icons.delete_outlined,
                label: 'Delete',
                color: Colors.red,
              ),
            ),
          ]);
        }

        return menuItems;
      },
    );
  }

  Widget _buildMenuItem({
    required IconData iconData,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(iconData, color: color, size: 28),
        SizedBox(width: spacing),
        Text(label, style: GoogleFonts.poppins(fontSize: 16, color: color)),
      ],
    );
  }

  Widget _buildBarcodeOptionsDialog(
    BuildContext context,
    BuildContext dialogContext,
  ) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorsConstants.white,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Choose an action',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: ColorsConstants.black,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: ColorsConstants.black,
                        size: 30,
                      ),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildBarcodeOption(
                icon: Icons.share,
                label: 'Save & Share',
                onTap: () => _onSaveAndShare(context, dialogContext),
              ),
              _buildBarcodeOption(
                icon: Icons.qr_code_rounded,
                label: 'Display',
                onTap: () => _onDisplayBarcode(context, dialogContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: ColorsConstants.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

enum MoreButtonEnum { barcode, edit, delete }
