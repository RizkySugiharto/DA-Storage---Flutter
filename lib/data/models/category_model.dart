class Category {
  final int id;
  final String name;
  final String description;

  Category({required this.id, required this.name, this.description = ''});

  static final none = Category(id: -1, name: 'None', description: '');

  static Category fromJSON(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
