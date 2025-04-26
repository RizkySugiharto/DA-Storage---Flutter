import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/supplier_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/suppliers_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_text_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() => _AddSupplierScreenState();
}

class _AddSupplierScreenState extends State<AddSupplierScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  static final _emailRegex = RegExp(r"^.+([@][a-z]+.[a-z]+)$");
  static final _phoneNumberRegex = RegExp(r"^[+]\d{1,3} \d+$");

  void _onConfirmPressed() async {
    if (_nameController.text.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Name field are required to fill",
        alertType: AlertBannerType.error,
      );
      return;
    }

    if (_emailController.text.isNotEmpty &&
        !_emailRegex.hasMatch(_emailController.text)) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Email field isn't valid",
        alertType: AlertBannerType.error,
      );
      return;
    }
    if (_phoneNumberController.text.isNotEmpty &&
        !_phoneNumberRegex.hasMatch(_phoneNumberController.text)) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Phone number field isn't valid",
        alertType: AlertBannerType.error,
      );
      return;
    }

    final newSupplier = await SuppliersApi.post(
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
    );

    if (!mounted) {
      return;
    }

    if (newSupplier != Supplier.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully add the supplier. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to add the supplier",
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
                        ScreenLabelWidget(label: 'Add Supplier'),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Supplier's name",
          ),
          InputTextWidget(
            label: 'Email',
            textController: _emailController,
            hint: "Supplier's email (if exists, e.g. user@gmail.com)",
            multiLine: true,
          ),
          InputTextWidget(
            label: 'Phone Number',
            textController: _phoneNumberController,
            hint: "Supplier's phone number (if exists, e.g. +62 123456789)",
            multiLine: true,
          ),
        ],
      ),
    );
  }
}
