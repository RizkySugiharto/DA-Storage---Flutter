import 'dart:io';

import 'package:da_storage/data/constants/colors_constants.dart';
import 'package:da_storage/data/constants/route_constants.dart';
import 'package:da_storage/data/notifiers/alert_notifiers.dart';
import 'package:da_storage/data/utils/api_utils.dart';
import 'package:da_storage/presentation/screens/accounts_screen.dart';
import 'package:da_storage/presentation/screens/add_account_screen.dart';
import 'package:da_storage/presentation/screens/add_category_screen.dart';
import 'package:da_storage/presentation/screens/add_customer_screen.dart';
import 'package:da_storage/presentation/screens/add_product_screen.dart';
import 'package:da_storage/presentation/screens/add_supplier_screen.dart';
import 'package:da_storage/presentation/screens/categories_screen.dart';
import 'package:da_storage/presentation/screens/add_transaction_screen.dart';
import 'package:da_storage/presentation/screens/edit_account_screen.dart';
import 'package:da_storage/presentation/screens/edit_category_screen.dart';
import 'package:da_storage/presentation/screens/edit_customer_screen.dart';
import 'package:da_storage/presentation/screens/edit_product_screen.dart';
import 'package:da_storage/presentation/screens/edit_supplier_screen.dart';
import 'package:da_storage/presentation/screens/history_screen.dart';
import 'package:da_storage/presentation/screens/home_screen.dart';
import 'package:da_storage/presentation/screens/login_screen.dart';
import 'package:da_storage/presentation/screens/notification_settings_screen.dart';
import 'package:da_storage/presentation/screens/products_screen.dart';
import 'package:da_storage/presentation/screens/reports_screen.dart';
import 'package:da_storage/presentation/screens/scan_barcode_screen.dart';
import 'package:da_storage/presentation/screens/select_customer_screen.dart';
import 'package:da_storage/presentation/screens/select_products_screen.dart';
import 'package:da_storage/presentation/screens/select_supplier_screen.dart';
import 'package:da_storage/presentation/screens/settings_screen.dart';
import 'package:da_storage/presentation/screens/suppliers_and_customers_screen.dart';
import 'package:da_storage/presentation/screens/transaction_details_screen.dart';
import 'package:da_storage/presentation/utils/alert_banner_utils.dart';
import 'package:flutter/material.dart';
import 'package:da_storage/data/constants/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:observe_internet_connectivity/observe_internet_connectivity.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rest_api_client/rest_api_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

extension FileNameExtension on FileSystemEntity {
  String? get name {
    return path.split(Platform.pathSeparator).last;
  }
}

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await RestApiClient.initFlutter();
  await ApiUtils.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    Permission.manageExternalStorage.request().then((status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        if (!context.mounted) {
          return;
        }

        AlertBannerUtils.showAlertBanner(
          context,
          message: 'Please allow the permission to continue the app :(',
          alertType: AlertBannerType.error,
        );
      }
    });

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
        tabBarTheme: TabBarThemeData(
          dividerHeight: 2,
          dividerColor: ColorsConstants.grey,
          indicatorColor: ColorsConstants.blue,
          labelColor: ColorsConstants.blue,
          overlayColor: WidgetStatePropertyAll(
            ColorsConstants.blue.withValues(alpha: 0.2),
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
        RouteConstants.history: (context) => HistoryScreen(),
        RouteConstants.reports: (context) => ReportsScreen(),
        RouteConstants.addTransaction: (context) => AddTransactionScreen(),
        RouteConstants.transactionDetails:
            (context) => TransactionDetailsScreen(),
        RouteConstants.selectProducts: (context) => SelectProductsScreen(),
        RouteConstants.selectSupplier: (context) => SelectSupplierScreen(),
        RouteConstants.selectCustomer: (context) => SelectCustomerScreen(),
        RouteConstants.settings: (context) => SettingsScreen(),
        RouteConstants.suppliersAndCustomers:
            (context) => SuppliersAndCustomersScreen(),
        RouteConstants.addSupplier: (context) => AddSupplierScreen(),
        RouteConstants.editSupplier: (context) => EditSupplierScreen(),
        RouteConstants.addCustomer: (context) => AddCustomerScreen(),
        RouteConstants.editCustomer: (context) => EditCustomerScreen(),
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
      builder: (context, child) {
        return Overlay(
          initialEntries: [
            OverlayEntry(
              builder: (context) {
                return InternetConnectivityListener(
                  connectivityListener: (context, hasInternetAccess) {
                    if (!context.mounted) {
                      return;
                    }

                    if (hasInternetAccess) {
                      AlertBannerUtils.showAlertBanner(
                        context,
                        message: 'Welcome, you now have an internet :)',
                        alertType: AlertBannerType.success,
                      );
                    } else {
                      AlertBannerUtils.showAlertBanner(
                        context,
                        message: 'You don\'t have an internet connection :(',
                        alertType: AlertBannerType.error,
                      );
                    }
                  },
                  child: child ?? Scaffold(),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
