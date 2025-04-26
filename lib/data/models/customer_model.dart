class Customer {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  static final none = Customer(
    id: -1,
    name: 'None',
    email: 'None',
    phoneNumber: 'None',
  );

  static Customer fromJSON(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
