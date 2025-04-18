import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ScreenLabelWidget extends StatelessWidget {
  final String label;
  final List<IconButton> actionButtons;
  final bool canGoBack;

  const ScreenLabelWidget({
    super.key,
    required this.label,
    this.actionButtons = const [],
    this.canGoBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Row(
            children:
                [...actionButtons] +
                (canGoBack ? [_getBackIconButton(context)] : []),
          ),
        ],
      ),
    );
  }

  IconButton _getBackIconButton(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: Icon(Icons.arrow_back, size: 34, weight: 5),
    );
  }
}
