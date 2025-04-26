import 'dart:io';
import 'package:da_storage/data/constants/colors_constants.dart';

import 'package:da_storage/data/models/account_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/accounts_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_avatar_widget.dart';
import 'package:da_storage/presentation/widgets/input_select_widget.dart';
import 'package:da_storage/presentation/widgets/input_text_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';

class AddAccountScreen extends StatefulWidget {
  const AddAccountScreen({super.key});

  @override
  State<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends State<AddAccountScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRole = Account.getAllRoleAsString().first;
  ImageProvider? _avatarImage;
  File? _avatarFile;

  void _onImageSelected(File image) {
    _avatarFile = image;
    setState(() {
      _avatarImage = FileImage(image);
    });
  }

  void _onConfirmPressed() async {
    final newCategory = await AccountsApi.post(
      avatarFile: _avatarFile,
      name: _nameController.text,
      email: _emailController.text,
      role: Account.getRoleByString(_selectedRole ?? 'staff'),
      password: _passwordController.text,
    );

    if (!mounted) {
      return;
    }

    if (newCategory != Account.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully add the account. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to add the account",
        alertType: AlertBannerType.error,
      );
    }
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.lightGrey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                HeaderWidget(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(label: 'Add Account'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Add',
                          cancelLabel: 'Cancel',
                          onConfirmPressed: () => _onConfirmPressed(),
                          onCancelPressed: () => _onCancelPressed(),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                NavbarWidget(),
              ],
            ),
            FloatingAddButtonWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildFormBox() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: const Offset(0, 1),
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        spacing: 24,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InputAvatarWidget(
            image: _avatarImage,
            onImageSelected: _onImageSelected,
          ),
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Accounts's name",
          ),
          InputTextWidget(
            label: 'Email',
            textController: _emailController,
            hint: "example123@gmail.com",
          ),
          InputSelectWidget(
            label: 'Role',
            options: Account.getAllRoleAsString(),
            hint: 'Choose one role',
            value: _selectedRole,
            onChanged: (selected) {
              setState(() {
                _selectedRole = selected;
              });
            },
          ),
          InputTextWidget(
            label: 'Password',
            textController: _passwordController,
            hint: "Accounts's password",
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
