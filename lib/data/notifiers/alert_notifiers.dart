import 'package:flutter/material.dart';

final ValueNotifier<AlertBannerType> alertTypeNotifier = ValueNotifier(
  AlertBannerType.info,
);
final ValueNotifier<String?> alertMessageNotifier = ValueNotifier(null);
final ValueNotifier<OverlayEntry?> alertOverlayEntryNotifier = ValueNotifier(
  null,
);

enum AlertBannerType { info, success, warning, error }
