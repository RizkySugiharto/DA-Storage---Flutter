import 'dart:io';
import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/placeholder_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:da_cashier/presentation/widgets/floating_add_button_widget.dart';
import 'package:da_cashier/presentation/widgets/header_widget.dart';
import 'package:da_cashier/presentation/widgets/input_avatar_widget.dart';
import 'package:da_cashier/presentation/widgets/input_text_widget.dart';
import 'package:da_cashier/presentation/widgets/navbar_widget.dart';
import 'package:da_cashier/presentation/widgets/screen_label_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController(
    text: PlaceholderConstants.username,
  );
  final _emailController = TextEditingController(
    text: PlaceholderConstants.email,
  );
  final _roleController = TextEditingController(
    text: PlaceholderConstants.role,
  );
  ImageProvider? _profileImage;
  bool _isSaving = false;

  void _onImageSelected(File selectedImage) {
    setState(() {
      _profileImage = FileImage(selectedImage);
    });
  }

  void _onSaveButtonPressed() {
    setState(() {
      _isSaving = true;
    });

    Future.delayed(Duration(seconds: 5)).then((_) {
      if (context.mounted) {
        AlertBannerUtils.showAlertBanner(
          // ignore: use_build_context_synchronously
          context,
          message: "Successfully save your account data",
          alertType: AlertBannerType.success,
        );
      }

      setState(() {
        _isSaving = false;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                        ScreenLabelWidget(label: 'Settings'),
                        _buildInformationBox(context),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            spacing: 16,
                            children: [
                              _buildSettingsItem(
                                icon: Icons.people,
                                title: 'Accounts Management',
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      RouteConstants.accounts,
                                    ),
                              ),
                              _buildSettingsItem(
                                icon: Icons.category,
                                title: 'Categories Management',
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      RouteConstants.categories,
                                    ),
                              ),
                              _buildSettingsItem(
                                icon: Icons.notifications,
                                title: 'Notification Settings',
                                onTap:
                                    () => Navigator.pushNamed(
                                      context,
                                      RouteConstants.notificationSettings,
                                    ),
                              ),
                              _buildSettingsItem(
                                icon: Icons.lock_reset,
                                title: 'Change Password',
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),
                        _buildLogoutSection(),
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

  Widget _buildInformationBox(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsConstants.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorsConstants.black.withValues(alpha: 0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InputAvatarWidget(
            image: _profileImage,
            onImageSelected: _onImageSelected,
          ),
          const SizedBox(height: 40),
          InputTextWidget(textController: _nameController, label: 'Name'),
          const SizedBox(height: 16),
          InputTextWidget(textController: _emailController, label: 'Email'),
          const SizedBox(height: 16),
          InputTextWidget(
            textController: _roleController,
            label: 'Role',
            readOnly: true,
          ),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.bottomRight,
      child: ElevatedButton.icon(
        onPressed: _isSaving ? null : _onSaveButtonPressed,
        icon: Icon(
          _isSaving ? Icons.hourglass_empty_outlined : Icons.save_outlined,
          size: 28,
          color: ColorsConstants.black,
        ),
        label: Text(
          _isSaving ? 'Saving...' : 'Save',
          style: GoogleFonts.poppins(
            color: ColorsConstants.black,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          backgroundColor: ColorsConstants.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: ColorsConstants.black, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: ColorsConstants.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 30, color: ColorsConstants.black),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: ColorsConstants.black,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: ColorsConstants.black,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42),
      child: GestureDetector(
        onTap: () {},
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded, size: 34),
            const SizedBox(width: 14),
            Text('Logout', style: GoogleFonts.poppins(fontSize: 20)),
          ],
        ),
      ),
    );
  }
}
