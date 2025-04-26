import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class InputTextWidget extends StatefulWidget {
  final TextStyle? labelStyle;
  final String? value;
  final String? hint;
  final TextInputType? keyboardType;
  final void Function(String?)? onChanged;
  final String label;
  final TextEditingController textController;
  final bool readOnly;
  final bool enablePriceLabel;
  final bool enablePriceFormat;
  final bool obscureText;
  final bool multiLine;

  const InputTextWidget({
    super.key,
    this.labelStyle,
    this.value,
    this.hint,
    this.keyboardType,
    this.onChanged,
    this.readOnly = false,
    this.enablePriceLabel = false,
    this.enablePriceFormat = false,
    this.obscureText = false,
    this.multiLine = false,
    required this.label,
    required this.textController,
  });

  @override
  State<InputTextWidget> createState() => _InputTextWidgetState();
}

class _InputTextWidgetState extends State<InputTextWidget> {
  final NumberFormat _priceFormat = NumberFormat.decimalPattern('ID-id');

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.enablePriceLabel
            ? Text.rich(
              TextSpan(
                text: widget.label,
                style:
                    widget.labelStyle?.merge(
                      GoogleFonts.poppins(color: ColorsConstants.black),
                    ) ??
                    GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: ColorsConstants.black,
                    ),
                children: [
                  TextSpan(
                    text: ' (Rupiah / Rp)',
                    style:
                        widget.labelStyle?.merge(
                          GoogleFonts.poppins(color: ColorsConstants.grey),
                        ) ??
                        GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: ColorsConstants.grey,
                        ),
                  ),
                ],
              ),
            )
            : Text(
              widget.label,
              style:
                  widget.labelStyle ??
                  GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: ColorsConstants.black,
                  ),
            ),
        const SizedBox(height: 8),
        TextField(
          controller: widget.textController,
          readOnly: widget.readOnly,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          maxLines: widget.multiLine ? null : 1,
          inputFormatters:
              widget.enablePriceFormat
                  ? [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'[-][0-9]|[0-9]'),
                    ),
                  ]
                  : [],
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 16,
              color: ColorsConstants.black.withValues(alpha: 0.35),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          onChanged: (value) {
            if (widget.onChanged != null) {
              widget.onChanged!(value);
            }

            if (!widget.enablePriceFormat ||
                widget.textController.text.isEmpty) {
              return;
            }

            setState(() {
              widget.textController.value = TextEditingValue(
                text: _priceFormat.format(
                  int.parse(widget.textController.text.replaceAll('.', '')),
                ),
              );
            });
          },
          style: GoogleFonts.poppins(
            fontSize: 16,
            color:
                widget.readOnly ? ColorsConstants.grey : ColorsConstants.black,
          ),
        ),
      ],
    );
  }
}
