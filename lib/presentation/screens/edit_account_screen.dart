import 'dart:io';
import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/models/account_model.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/input_avatar_widget.dart';
import 'package:da_cashier/presentation/widgets/input_select_widget.dart';
import 'package:da_cashier/presentation/widgets/input_text_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';

class EditAccountScreen extends StatefulWidget {
  const EditAccountScreen({super.key});

  @override
  State<EditAccountScreen> createState() => _EditAccountScreenState();
}

class _EditAccountScreenState extends State<EditAccountScreen> {
  late final _nameController = TextEditingController(text: account.name);
  late final _emailController = TextEditingController(text: account.email);
  late final _passwordController = TextEditingController();
  late String? _selectedRole = account.getRoleAsString();
  late ImageProvider? _avatarImage = NetworkImage(account.avatarUrl);

  final account = Account(
    id: 1,
    avatarUrl:
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNt9UpcsobJNOGFHPeBt-88iRmqjflBnIjhw&s',
    name: 'Udin Surudin',
    email: 'udinsurudin12345@gmail.com',
    role: AccountRole.administrator,
  );

  void _onAvatarSelected(File image) {
    setState(() {
      _avatarImage = FileImage(image);
    });
  }

  void _onConfirmPressed(BuildContext context) {
    AlertBannerUtils.popWithAlertBanner(
      context,
      message: "Successfully edit the account",
      alertType: AlertBannerType.success,
    );
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context, false);
  }

  void _fetchAccount(int accountId) {}

  @override
  Widget build(BuildContext context) {
    final accountId = ModalRoute.of(context)!.settings.arguments as int;
    _fetchAccount(accountId);

    return Scaffold(
      backgroundColor: ColorsConstants.lightGrey,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              children: [
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                ),
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
                          onConfirmPressed: () => _onConfirmPressed(context),
                          onCancelPressed: () => _onCancelPressed(context),
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
            onImageSelected: _onAvatarSelected,
          ),
          InputTextWidget(
            label: 'Account ID',
            textController: TextEditingController(text: account.id.toString()),
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
