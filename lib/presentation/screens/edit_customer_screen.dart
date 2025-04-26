import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/models/customer_model.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/providers/customers_api.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:da_storage/presentation/widgets/confirmation_buttons_widget.dart';
import 'package:da_storage/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_storage/presentation/widgets/header_widget.dart';
import 'package:da_storage/presentation/widgets/input_text_widget.dart';
import 'package:da_storage/presentation/widgets/navbar_widget.dart';
import 'package:da_storage/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class EditCustomerScreen extends StatefulWidget {
  const EditCustomerScreen({super.key});

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late final _nameController = TextEditingController(text: _customer.name);
  late final _emailController = TextEditingController(text: _customer.email);
  late final _phoneNumberController = TextEditingController(
    text: _customer.phoneNumber,
  );
  static final _emailRegex = RegExp(r"^.+([@][a-z]+.[a-z]+)$");
  static final _phoneNumberRegex = RegExp(r"^[+]\d{1,3} \d+$");
  bool _isLoading = false;
  Customer _customer = Customer.none;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final category = ModalRoute.of(context)!.settings.arguments as Customer;
      _fetchCustomer(category.id);
    });
  }

  void _onConfirmPressed(BuildContext context) async {
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

    setState(() {
      _isLoading = true;
    });

    final newCustomer = await CustomersApi.put(
      id: _customer.id,
      name: _nameController.text,
      email: _emailController.text,
      phoneNumber: _phoneNumberController.text,
    );

    if (!context.mounted) {
      return;
    }

    if (newCustomer != Customer.none) {
      AlertBannerUtils.popWithAlertBanner(
        context,
        message: "Successfully edit the customer. Refresh to see the changes.",
        alertType: AlertBannerType.success,
      );
    } else {
      AlertBannerUtils.showAlertBanner(
        context,
        message: "Failed to edit the customer.",
        alertType: AlertBannerType.error,
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _onCancelPressed(BuildContext context) {
    Navigator.pop(context);
  }

  void _fetchCustomer(int customerId) async {
    _customer = await CustomersApi.getSingleCustomer(customerId);
    setState(() {
      _nameController.text = _customer.name;
      _emailController.text = _customer.email;
      _phoneNumberController.text = _customer.phoneNumber;
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
                        ScreenLabelWidget(label: 'Edit Customer'),
                        _buildFormBox(),
                        ConfirmationButtonsWidget(
                          confirmLabel: 'Save',
                          cancelLabel: 'Cancel',
                          isLoading: _isLoading,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InputTextWidget(
            label: 'Customer ID',
            readOnly: true,
            textController: TextEditingController(
              text: _customer.id.toString(),
            ),
            hint: "Customer's ID",
          ),
          InputTextWidget(
            label: 'Name',
            textController: _nameController,
            hint: "Customer's name",
          ),
          InputTextWidget(
            label: 'Email',
            textController: _emailController,
            hint: "Customer's email (if exists, e.g. user@gmail.com)",
            multiLine: true,
          ),
          InputTextWidget(
            label: 'Phone Number',
            textController: _phoneNumberController,
            hint: "Customer's phone number (if exists, e.g. +62 123456789)",
            multiLine: true,
          ),
        ],
      ),
    );
  }
}
