import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ConfirmationButtonsWidget extends StatelessWidget {
  final VoidCallback? onConfirmPressed;
  final VoidCallback? onCancelPressed;
  final String confirmLabel;
  final String cancelLabel;
  final double minimumButtonWidth;
  bool isLoading;

  ConfirmationButtonsWidget({
    super.key,
    this.onConfirmPressed,
    this.onCancelPressed,
    this.minimumButtonWidth = 150,
    this.isLoading = false,
    required this.confirmLabel,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final hasEnoughSpace =
              availableWidth >= (minimumButtonWidth * 2 - 16);

          return hasEnoughSpace
              ? Row(
                spacing: 16,
                children: [
                  Expanded(child: _buildConfirmButton()),
                  Expanded(child: _buildCancelButton()),
                ],
              )
              : Column(
                spacing: 16,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: _buildConfirmButton(),
                  ),
                  SizedBox(width: double.infinity, child: _buildCancelButton()),
                ],
              );
        },
      ),
    );
  }

  Widget _buildConfirmButton() {
    return ElevatedButton(
      onPressed: () {
        if (!isLoading || onConfirmPressed != null) {
          onConfirmPressed!();
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(ColorsConstants.black),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        minimumSize: WidgetStatePropertyAll(Size(minimumButtonWidth, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: ColorsConstants.black,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
      ),
      child:
          isLoading
              ? CircularProgressIndicator(color: ColorsConstants.white)
              : Text(
                confirmLabel,
                style: GoogleFonts.poppins(
                  color: ColorsConstants.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
    );
  }

  Widget _buildCancelButton() {
    return ElevatedButton(
      onPressed: () {
        if (!isLoading || onCancelPressed != null) {
          onCancelPressed!();
        }
      },
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(ColorsConstants.white),
        padding: WidgetStatePropertyAll(
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        minimumSize: WidgetStatePropertyAll(Size(minimumButtonWidth, 0)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: ColorsConstants.black,
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
        ),
      ),
      child:
          isLoading
              ? CircularProgressIndicator(color: ColorsConstants.black)
              : Text(
                cancelLabel,
                style: GoogleFonts.poppins(
                  color: ColorsConstants.black,
                  fontSize: 24,
                ),
              ),
    );
  }
}
