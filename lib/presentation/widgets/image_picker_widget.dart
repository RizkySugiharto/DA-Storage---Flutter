import 'dart:io';

import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class ImagePickerWidget extends StatelessWidget {
  final Function(File)? onImageSelected;
  final double size;

  ImageSource _selectedSource = ImageSource.gallery;
  BuildContext? _dialogContext;

  ImagePickerWidget({super.key, this.onImageSelected, required this.size});

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: _selectedSource);

    if (image != null && onImageSelected != null) {
      onImageSelected!(File(image.path));
    }

    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () => showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              _dialogContext = dialogContext;
              return _buildOptionsDialog(dialogContext);
            },
          ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ColorsConstants.grey,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt,
          color: ColorsConstants.white,
          size: size * 0.7,
        ),
      ),
    );
  }

  Widget _buildOptionsDialog(BuildContext dialogContext) {
    return Align(
      alignment: Alignment.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: ColorsConstants.white,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      'Choose a method',
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
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _buildOption(
                icon: Icons.image_search,
                label: 'Gallery',
                imageSource: ImageSource.gallery,
              ),
              _buildOption(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                imageSource: ImageSource.camera,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required ImageSource imageSource,
  }) {
    return Material(
      color: ColorsConstants.white,
      child: InkWell(
        onTap: () {
          _selectedSource = imageSource;
          _pickImage();
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 32),
              const SizedBox(width: 16),
              Text(label, style: GoogleFonts.poppins(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
  }
}
