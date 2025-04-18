import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/widgets/alert_banner_widget.dart';
import 'package:flutter/material.dart';

class AlertBannerUtils {
  static void setAlert({
    required String message,
    AlertBannerType alertType = AlertBannerType.info,
  }) {
    alertMessageNotifier.value = message;
    alertTypeNotifier.value = alertType;
  }

  static void clearAlertBanner() {
    alertOverlayEntryNotifier.value?.remove();
    alertOverlayEntryNotifier.value?.dispose();
    alertOverlayEntryNotifier.value = null;
  }

  static void showAlertBanner(
    BuildContext context, {
    required String message,
    AlertBannerType alertType = AlertBannerType.info,
  }) {
    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: AlertBannerWidget(alertType: alertType, message: message),
          ),
        );
      },
    );

    clearAlertBanner();
    alertOverlayEntryNotifier.value = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
  }

  static void popWithAlertBanner(
    BuildContext context, {
    required String message,
    AlertBannerType alertType = AlertBannerType.info,
  }) {
    final overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: AlertBannerWidget(alertType: alertType, message: message),
          ),
        );
      },
    );

    clearAlertBanner();
    alertOverlayEntryNotifier.value = overlayEntry;
    Overlay.of(context).insert(overlayEntry);
    Navigator.pop(context);
  }
}
