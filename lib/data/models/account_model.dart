class Account {
  final int id;
  final String avatarUrl;
  final String name;
  final String email;
  final AccountRole role;
  static final none = Account(id: 0, name: '', email: '');

  Account({
    required this.id,
    this.avatarUrl =
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTNt9UpcsobJNOGFHPeBt-88iRmqjflBnIjhw&s',
    required this.name,
    required this.email,
    this.role = AccountRole.cashier,
  });

  String get firstName {
    return name.split(' ').first;
  }

  String getRoleAsString() {
    switch (role) {
      case AccountRole.cashier:
        return 'Cashier';
      case AccountRole.administrator:
        return 'Administrator';
    }
  }

  static List<String> getAllRoleAsString() {
    return ['Cashier', 'Administrator'];
  }
}

enum AccountRole { cashier, administrator }
