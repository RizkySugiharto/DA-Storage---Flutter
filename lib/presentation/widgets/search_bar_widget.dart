import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController searchController;
  final String hintText;
  final void Function(String) onSubmitted;

  const SearchBarWidget({
    super.key,
    required this.searchController,
    required this.onSubmitted,
    required this.hintText,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: ColorsConstants.black,
            width: 2,
            strokeAlign: BorderSide.strokeAlignCenter,
          ),
        ),
        child: TextField(
          onSubmitted: widget.onSubmitted,
          controller: widget.searchController,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.5),
              fontSize: 18,
            ),
            fillColor: Colors.transparent,
            suffixIcon: IconButton(
              icon: Icon(Icons.search, size: 30),
              onPressed: () {
                FocusManager.instance.primaryFocus?.unfocus();
                widget.onSubmitted(widget.searchController.text);
              },
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
          textInputAction: TextInputAction.search,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
