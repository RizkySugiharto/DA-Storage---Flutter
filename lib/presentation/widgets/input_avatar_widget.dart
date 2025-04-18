import 'dart:io';

import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/presentation/utils/responsive_utils.dart';
import 'package:da_cashier/presentation/widgets/image_picker_widget.dart';
import 'package:flutter/material.dart';

class InputAvatarWidget extends StatelessWidget {
  final void Function(File)? onImageSelected;
  final ImageProvider? image;

  const InputAvatarWidget({
    super.key,
    this.image,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = ResponsiveUtils.isTablet(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);
    final double profileImageSize =
        isDesktop ? 160.0 : (isTablet ? 140.0 : 120.0);

    return Stack(
      children: <Widget>[
        Container(
          width: profileImageSize,
          height: profileImageSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: image ?? NetworkImage(PlaceholderConstants.avatarUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: ImagePickerWidget(
            size: profileImageSize * 0.36,
            onImageSelected: onImageSelected,
          ),
        ),
      ],
    );
  }
}
