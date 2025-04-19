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
    this.role = AccountRole.staff,
  });

  String get firstName {
    return name.split(' ').first;
  }

  static Account fromJSON(Map<String, dynamic> json) {
    return Account(
      id: json['id'] ?? 0,
      avatarUrl: json['avatar_url'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: getRoleByString(json['role']),
    );
  }

  String getRoleAsString() {
    switch (role) {
      case AccountRole.admin:
        return 'Admin';
      case AccountRole.staff:
        return 'Staff';
    }
  }

  static List<String> getAllRoleAsString() {
    return ['Cashier', 'Administrator'];
  }

  static AccountRole getRoleByString(String role) {
    return {'admin': AccountRole.admin, 'staff': AccountRole.staff}[role] ??
        AccountRole.staff;
  }
}

enum AccountRole { admin, staff }
