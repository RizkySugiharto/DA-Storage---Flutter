import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:flutter/scheduler.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late final _nameController = TextEditingController(text: _account.name);
  late final _emailController = TextEditingController(text: _account.email);
  late final _passwordController = TextEditingController();
  late String? _selectedRole = _account.getRoleAsString();
  File? _selectedAvatarFile;
  late ImageProvider? _avatarImage = CachedNetworkImageProvider(
    _account.avatarUrl,
  );
  bool _isLoading = false;
  Account _account = Account.none;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final account = ModalRoute.of(context)!.settings.arguments as Account;
      _fetchAccount(account.id);
    });
  }

  void _onConfirmPressed() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        (_selectedRole?.isEmpty ?? false)) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Name, email, and role fields are required to fill",
        alertType: AlertBannerType.error,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final newAccount = await AccountsApi.put(
      id: _account.id,
      avatarFile: _selectedAvatarFile,
      name: _nameController.text,
      email: _emailController.text,
      role:
          {
            'Admin': AccountRole.admin,
            'Staff': AccountRole.staff,
          }[_selectedRole] ??
          AccountRole.staff,
      password:
          _passwordController.text.isNotEmpty ? _passwordController.text : null,
    );

    if (!mounted) {
      return;
    }

    if (newAccount != Account.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully edit the account. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to edit the account.",
        alertType: AlertBannerType.error,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCancelPressed() {
    Navigator.pop(context);
  }

  void _fetchAccount(int accountId) async {
    _account = await AccountsApi.getSingleAccount(accountId);
    setState(() {
      _avatarImage = CachedNetworkImageProvider(_account.avatarUrl);
      _nameController.text = _account.name;
      _emailController.text = _account.email;
      _selectedRole = _account.getRoleAsString();
    });
  }

  void _onImageSelected(File selectedImage) {
    _selectedAvatarFile = selectedImage;
    setState(() {
      _avatarImage = FileImage(selectedImage);
    });
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
                        ScreenLabelWidget(label: 'Edit Account'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Save',
                          cancelLabel: 'Cancel',
                          isLoading: _isLoading,
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
            label: 'Account ID',
            textController: TextEditingController(text: _account.id.toString()),
            hint: "Accounts's ID",
            readOnly: true,
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
            label: 'New Password',
            textController: _passwordController,
            hint: "Accounts's password",
            obscureText: true,
          ),
        ],
      ),
    );
  }
}
