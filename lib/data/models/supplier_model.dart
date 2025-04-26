class Supplier {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;

  Supplier({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  static final none = Supplier(
    id: -1,
    name: 'None',
    email: 'None',
    phoneNumber: 'None',
  );

  static Supplier fromJSON(Map<String, dynamic> json) {
    return Supplier(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phone_number'] ?? '',
    );
  }
}
