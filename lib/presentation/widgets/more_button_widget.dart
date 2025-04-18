import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                return _buildBarcodeOptionsDialog(dialogContext);
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

  Widget _buildBarcodeOptionsDialog(BuildContext dialogContext) {
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
                label: 'Share',
                onTap: () {},
              ),
              _buildBarcodeOption(
                icon: Icons.folder_copy,
                label: 'Save to Files',
                onTap: () {},
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
