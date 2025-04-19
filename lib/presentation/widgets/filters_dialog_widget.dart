import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef FilterItem = String;
typedef FilterList = List<FilterItem>;
typedef FilterSet = Set<FilterItem>;
typedef FilterSectionTitle = String;

class FilterDialogSectionData {
  final FilterList filterList;
  final bool isChoice;

  FilterDialogSectionData({required this.filterList, this.isChoice = false});
}

class FiltersDialogWidget extends StatefulWidget {
  final BuildContext dialogContext;
  final String title;
  final Map<FilterSectionTitle, FilterDialogSectionData> filterSections;
  final Map<FilterSectionTitle, FilterSet>? currentFilters;
  final void Function()? onDialogClosed;
  final void Function(bool, FilterItem?, Map<FilterSectionTitle, FilterSet>)?
  onFilterSelected;

  const FiltersDialogWidget({
    super.key,
    required this.dialogContext,
    required this.title,
    required this.filterSections,
    this.currentFilters,
    this.onDialogClosed,
    this.onFilterSelected,
  });

  @override
  State<FiltersDialogWidget> createState() => _ChipsDialogWidgetState();
}

class _ChipsDialogWidgetState extends State<FiltersDialogWidget> {
  late final Map<FilterSectionTitle, FilterSet> _crrntFilters =
      widget.currentFilters ??
      widget.filterSections.map(
        (filterSectionTitle, _) => MapEntry(filterSectionTitle, <FilterItem>{}),
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
                    widget.filterSections.keys.map((filterSectionTitle) {
                      return SizedBox(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filterSectionTitle,
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
                                  [
                                    _buildDefaultFilterChip(filterSectionTitle),
                                  ] +
                                  widget
                                      .filterSections[filterSectionTitle]!
                                      .filterList
                                      .map((FilterItem filterItem) {
                                        return _buildFilterChip(
                                          filterSectionTitle,
                                          filterItem,
                                        );
                                      })
                                      .toList(),
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

  Widget _buildFilterChip(
    FilterSectionTitle filterSectionTitle,
    FilterItem filterItem,
  ) {
    final bool isSelected =
        _crrntFilters[filterSectionTitle]?.contains(filterItem) ?? false;
    final Color color = _getColorBySelected(isSelected);

    return FilterChip(
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
        filterItem,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          if (widget.filterSections[filterSectionTitle]?.isChoice ?? false) {
            if (selected) {
              _crrntFilters[filterSectionTitle]?.clear();
              _crrntFilters[filterSectionTitle]?.add(filterItem);
            } else {
              _crrntFilters[filterSectionTitle]?.clear();
            }
          } else if (widget.filterSections[filterSectionTitle]?.isChoice ==
              false) {
            selected
                ? _crrntFilters[filterSectionTitle]?.add(filterItem)
                : _crrntFilters[filterSectionTitle]?.remove(filterItem);
          }

          if (widget.onFilterSelected != null) {
            widget.onFilterSelected!(selected, filterItem, _crrntFilters);
          }
        });
      },
    );
  }

  Widget _buildDefaultFilterChip(String filterSectionTitle) {
    final bool isAll = _crrntFilters[filterSectionTitle]!.isEmpty;
    final Color color = _getColorBySelected(isAll);

    return FilterChip(
      selected: isAll,
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
        'All',
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: color,
        ),
      ),
      onSelected: (bool selected) {
        setState(() {
          if (selected) {
            _crrntFilters[filterSectionTitle]?.clear();
            if (widget.onFilterSelected != null) {
              widget.onFilterSelected!(selected, null, _crrntFilters);
            }
          }
        });
      },
    );
  }

  Color _getColorBySelected(bool isSelected) =>
      isSelected ? ColorsConstants.blue : ColorsConstants.black;
}
