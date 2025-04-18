import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef SortSectionData = Map<String, Enum>;
typedef SortSet = Set<Enum>;
typedef SortSectionList = String;

class SortsDialogWidget extends StatefulWidget {
  final BuildContext dialogContext;
  final String title;
  final Map<SortSectionList, SortSectionData> sortSections;
  final void Function()? onDialogClosed;
  final void Function(bool, Enum?, Map<String, SortSet>)? onSortSelected;

  const SortsDialogWidget({
    super.key,
    required this.dialogContext,
    required this.title,
    required this.sortSections,
    this.onDialogClosed,
    this.onSortSelected,
  });

  @override
  State<SortsDialogWidget> createState() => _ChipsDialogWidgetState();
}

class _ChipsDialogWidgetState extends State<SortsDialogWidget> {
  late final Map<SortSectionList, SortSet> _crrntSortings = widget.sortSections
      .map(
        (sortSectionTitle, sortSectionData) =>
            MapEntry(sortSectionTitle, <Enum>{sortSectionData.values.first}),
      );

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorsConstants.white,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    widget.title,
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
                    onPressed: () {
                      if (widget.onDialogClosed != null) {
                        widget.onDialogClosed!();
                      }
                      Navigator.of(widget.dialogContext).pop();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Column(
                spacing: 24,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children:
                    widget.sortSections.keys.map((sortSectionTitle) {
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sortSectionTitle,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: ColorsConstants.black,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children:
                                  widget.sortSections[sortSectionTitle]!.keys.map((
                                    String sortName,
                                  ) {
                                    final sortEnum =
                                        widget
                                            .sortSections[sortSectionTitle]![sortName];

                                    return _buildSortChip(
                                      sortSectionTitle,
                                      sortName,
                                      sortEnum!,
                                    );
                                  }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSortChip(
    SortSectionList sortSectionTitle,
    String sortName,
    Enum sortEnum,
  ) {
    final bool isSelected =
        _crrntSortings[sortSectionTitle]?.contains(sortEnum) ?? false;
    final Color color = _getColorBySelected(isSelected);

    return ChoiceChip(
      selected: isSelected,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(
          color: color,
          width: 1.5,
          strokeAlign: BorderSide.strokeAlignCenter,
        ),
      ),
      backgroundColor: ColorsConstants.white,
      selectedColor: ColorsConstants.blue.withValues(alpha: 0.2),
      label: Text(
        sortName,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _crrntSortings[sortSectionTitle]?.clear();
            _crrntSortings[sortSectionTitle]?.add(sortEnum);
          }

          if (widget.onSortSelected != null) {
            widget.onSortSelected!(selected, sortEnum, _crrntSortings);
          }
        });
      },
    );
  }

  Color _getColorBySelected(bool isSelected) =>
      isSelected ? ColorsConstants.blue : ColorsConstants.black;
}
