import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputSelectWidget extends StatelessWidget {
  final String label;
  final TextStyle? labelStyle;
  final String? value;
  final String? hint;
  final List<String> options;
  final Function(String?) onChanged;

  const InputSelectWidget({
    super.key,
    this.value,
    this.hint,
    this.labelStyle,
    required this.label,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              labelStyle ??
              GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: ColorsConstants.black,
              ),
        ),
        const SizedBox(height: 8),
        _buildDropdown(),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: ColorsConstants.lightGrey,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: ColorsConstants.black, width: 1),
      ),
      child: DropdownButtonHideUnderline(
        child: ButtonTheme(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: ColorsConstants.black,
            ),
            iconSize: 30,
            elevation: 16,
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(8),
            hint: Text(
              hint ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: ColorsConstants.black.withValues(alpha: 0.35),
              ),
            ),
            items:
                options
                    .map(
                      (opt) => DropdownMenuItem(
                        value: opt,
                        child: Text(
                          opt,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: ColorsConstants.black,
                          ),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (newValue) => onChanged(newValue),
          ),
        ),
      ),
    );
  }
}
