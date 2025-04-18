import 'dart:io';

import 'package:da_cashier/data/constants/colors_constants.dart';
import 'package:da_cashier/data/constants/route_constants.dart';
import 'package:da_cashier/data/utils/api_utils.dart';
import 'package:da_cashier/presentation/screens/accounts_screen.dart';
import 'package:da_cashier/presentation/screens/add_account_screen.dart';
import 'package:da_cashier/presentation/screens/add_category_screen.dart';
import 'package:da_cashier/presentation/screens/add_product_screen.dart';
import 'package:da_cashier/presentation/screens/categories_screen.dart';
import 'package:da_cashier/presentation/screens/create_transaction_screen.dart';
import 'package:da_cashier/presentation/screens/edit_account_screen.dart';
import 'package:da_cashier/presentation/screens/edit_category_screen.dart';
import 'package:da_cashier/presentation/screens/edit_product_screen.dart';
// import 'package:da_cashier/presentation/screens/history_screen.dart';
import 'package:da_cashier/presentation/screens/home_screen.dart';
import 'package:da_cashier/presentation/screens/login_screen.dart';
import 'package:da_cashier/presentation/screens/notification_settings_screen.dart';
import 'package:da_cashier/presentation/screens/products_screen.dart';
import 'package:da_cashier/presentation/screens/reports_screen.dart';
import 'package:da_cashier/presentation/screens/scan_barcode_screen.dart';
import 'package:da_cashier/presentation/screens/select_products_screen.dart';
import 'package:da_cashier/presentation/screens/settings_screen.dart';
import 'package:da_cashier/presentation/screens/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:da_cashier/data/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rest_api_client/rest_api_client.dart';

extension FileNameExtension on FileSystemEntity {
  String? get name {
    return path.split(Platform.pathSeparator).last;
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RestApiClient.initFlutter();
  await ApiUtils.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: ColorsConstants.blue),
        highlightColor: ColorsConstants.blue.withValues(alpha: 0.2),
        splashColor: ColorsConstants.blue.withValues(alpha: 0.2),
        iconButtonTheme: IconButtonThemeData(
          style: ButtonStyle(
            overlayColor: WidgetStateProperty.all<Color>(
              ColorsConstants.blue.withValues(alpha: 0.2),
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            overlayColor: ColorsConstants.blue.withValues(alpha: 0.2),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: ColorsConstants.blue,
          hoverColor: ColorsConstants.blue,
          hintStyle: GoogleFonts.poppins(
            fontSize: 16,
            color: ColorsConstants.black.withValues(alpha: 0.35),
          ),
          filled: true,
          fillColor: ColorsConstants.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: ColorsConstants.black, width: 1),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        primaryColor: ColorsConstants.blue,
        hoverColor: ColorsConstants.blue,
        focusColor: ColorsConstants.blue,
        shadowColor: ColorsConstants.black.withValues(alpha: 0.05),
        iconTheme: IconThemeData(color: ColorsConstants.black),
        scaffoldBackgroundColor: ColorsConstants.lightGrey,
      ),
      initialRoute: RouteConstants.login,
      routes: {
        RouteConstants.login: (context) => LoginScreen(),
        RouteConstants.home: (context) => HomeScreen(),
        RouteConstants.scanBarcode: (context) => ScanBarcodeScreen(),
        RouteConstants.products: (context) => ProductsScreen(),
        RouteConstants.addProduct: (context) => AddProductScreen(),
        RouteConstants.editProduct: (context) => EditProductScreen(),
        // RouteConstants.history: (context) => HistoryScreen(),
        RouteConstants.reports: (context) => ReportsScreen(),
        RouteConstants.createTransaction:
            (context) => CreateTransactionScreen(),
        RouteConstants.transactionDetails:
            (context) => TransactionDetailsScreen(),
        RouteConstants.selectProducts: (context) => SelectProductsScreen(),
        RouteConstants.settings: (context) => SettingsScreen(),
        RouteConstants.accounts: (context) => AccountsScreen(),
        RouteConstants.addAccount: (context) => AddAccountScreen(),
        RouteConstants.editAccount: (context) => EditAccountScreen(),
        RouteConstants.notificationSettings:
            (context) => NotificationSettingsScreen(),
        RouteConstants.categories: (context) => CategoriesScreen(),
        RouteConstants.addCategory: (context) => AddCategoryScreen(),
        RouteConstants.editCategory: (context) => EditCategoryScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
