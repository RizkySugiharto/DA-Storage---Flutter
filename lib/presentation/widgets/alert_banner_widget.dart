import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:flutter/material.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:google_fonts/google_fonts.dart';

class AlertBannerWidget extends StatefulWidget {
  final AlertBannerType alertType;
  final String message;
  static const double _iconSize = 30;

  const AlertBannerWidget({
    super.key,
    required this.alertType,
    required this.message,
  });

  @override
  State<AlertBannerWidget> createState() => _AlertBannerWidgetState();
}

class _AlertBannerWidgetState extends State<AlertBannerWidget> {
  @override
  Widget build(BuildContext context) {
    final foregroundColor = _getForegroundColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _getBackgroundColor(),
        boxShadow: [BoxShadow(blurRadius: 20, color: ColorsConstants.shadow)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 16,
        children: [
          Flexible(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                _getAlertIcon(foregroundColor),
                Flexible(
                  child: Text(
                    widget.message,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: AlertBannerUtils.clearAlertBanner,
            child: Icon(
              Icons.close_rounded,
              size: AlertBannerWidget._iconSize,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (widget.alertType) {
      case AlertBannerType.info:
        return Color(0xFF3B82F6);
      case AlertBannerType.success:
        return Color(0xFF34C759);
      case AlertBannerType.warning:
        return Color(0xFFBFE516);
      case AlertBannerType.error:
        return Color(0xFFEF4444);
    }
  }

  Color _getForegroundColor() {
    return [
          AlertBannerType.info,
          AlertBannerType.success,
          AlertBannerType.error,
        ].contains(widget.alertType)
        ? ColorsConstants.white
        : ColorsConstants.black;
  }

  Icon _getAlertIcon(Color iconColor) {
    switch (widget.alertType) {
      case AlertBannerType.info:
        return Icon(
          Icons.info,
          size: AlertBannerWidget._iconSize,
          color: iconColor,
        );
      case AlertBannerType.success:
        return Icon(
          Icons.check_circle,
          size: AlertBannerWidget._iconSize,
          color: iconColor,
        );
      case AlertBannerType.warning:
        return Icon(
          Icons.warning_rounded,
          size: AlertBannerWidget._iconSize,
          color: iconColor,
        );
      case AlertBannerType.error:
        return Icon(
          Icons.error,
          size: AlertBannerWidget._iconSize,
          color: iconColor,
        );
    }
  }
}
