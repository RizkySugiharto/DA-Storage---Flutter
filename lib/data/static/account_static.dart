import 'package:da_cashier/data/models/account_model.dart';

class AccountStatic {
  static String name = '';
  static AccountRole role = AccountRole.staff;
  static String avatarUrl = '';

  static bool isAdmin() {
    return role == AccountRole.admin;
  }
}
