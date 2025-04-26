import 'package:da_storage/data/models/account_model.dart';

class AccountStatic {
  static String name = '';
  static AccountRole role = AccountRole.staff;
  static String avatarUrl = '';

  static bool isAdmin() {
    return role == AccountRole.admin;
  }

  static void setByAccount(Account account) {
    AccountStatic.name = account.name;
    AccountStatic.avatarUrl = account.avatarUrl;
    AccountStatic.role = account.role;
  }
}
