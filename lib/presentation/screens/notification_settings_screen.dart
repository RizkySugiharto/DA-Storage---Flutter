import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _enableLowStockNotification = false;
  bool _enableEmptyStockNotification = false;
  final _lowStockController = TextEditingController(text: '5');

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
                HeaderWidget(
                  username: PlaceholderConstants.username,
                  avatarUrl: PlaceholderConstants.avatarUrl,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ScreenLabelWidget(
                          label: 'Notification Settings',
                          canGoBack: true,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            spacing: 16,
                            children: [
                              _buildSettingsItemWithSwitch(
                                label: 'Low Stock Item Notification',
                                description:
                                    'Notify when item reach low level stock',
                                value: _enableLowStockNotification,
                                onChanged: (value) {
                                  setState(() {
                                    _enableLowStockNotification = value;
                                  });
                                },
                              ),
                              _buildSettingsItemWithTextField(
                                label: 'Low Stock Trigger Value',
                                description:
                                    'How much stock of product to be marked as low level stock',
                                controller: _lowStockController,
                              ),
                              _buildSettingsItemWithSwitch(
                                label: 'Empty Stock Item Notification',
                                description:
                                    "Notify when item's stock is empty or 0",
                                value: _enableEmptyStockNotification,
                                onChanged: (value) {
                                  setState(() {
                                    _enableEmptyStockNotification = value;
                                  });
                                },
                              ),
                            ],
                          ),
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

  Widget _buildSettingsItemWithSwitch({
    required String label,
    required String description,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: GoogleFonts.poppins(fontSize: 16)),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: ColorsConstants.grey,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSettingsItemWithTextField({
    required String label,
    required String description,
    required TextEditingController controller,
    bool digitsOnly = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: ColorsConstants.white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 1),
            blurRadius: 2,
            color: ColorsConstants.shadow,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: GoogleFonts.poppins(fontSize: 16)),
          const SizedBox(height: 2),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: ColorsConstants.grey,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            inputFormatters:
                digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : [],
            keyboardType:
                digitsOnly ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              fillColor: ColorsConstants.lightGrey,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                  color: ColorsConstants.black,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
