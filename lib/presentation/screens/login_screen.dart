import 'package:da_cashier/data/constants/app_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/notifiers/alert_notifiers.dart';
import 'package:da_cashier/data/providers/auth_api.dart';
import 'package:da_cashier/data/utils/api_utils.dart';
import 'package:da_cashier/presentation/utils/alert_banner_utils.dart';
import 'package:flutter/material.dart';
import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      await ApiUtils.loadClientToken();
      if (context.mounted && ApiUtils.isLoggedIn()) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, RouteConstants.home);
      }
    });
  }

  void _onLoginPressed() async {
    if (!context.mounted) {
      return;
    }

    if (_emailController.text.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: 'Email can\'t be empty',
        alertType: AlertBannerType.error,
      );
      return;
    }
    if (_passwordController.text.isEmpty) {
      AlertBannerUtils.showAlertBanner(
        context,
        message: 'Password can\'t be empty',
        alertType: AlertBannerType.error,
      );
      return;
    }

    bool isLoggedIn = await AuthApi.login(
      _emailController.text,
      _passwordController.text,
    );

    if (isLoggedIn) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, RouteConstants.home);
    } else {
      AlertBannerUtils.showAlertBanner(
        // ignore: use_build_context_synchronously
        context,
        message: 'Email or password isn\'t valid',
        alertType: AlertBannerType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsConstants.lightGrey,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorsConstants.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: ColorsConstants.shadow,
                    offset: Offset(0, 1),
                    blurRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Login to\n${AppConstants.appName}',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: ColorsConstants.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(
                          label: 'Email',
                          controller: _emailController,
                          isPassword: false,
                        ),
                        const SizedBox(height: 24),
                        _buildInputField(
                          label: 'Password',
                          controller: _passwordController,
                          isPassword: true,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(35.0),
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        onPressed: _onLoginPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsConstants.blue,
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 60,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorsConstants.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: ColorsConstants.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorsConstants.black, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: ColorsConstants.blue, width: 1.5),
            ),
            fillColor: ColorsConstants.lightGrey,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 20,
            ),
          ),
        ),
      ],
    );
  }
}
