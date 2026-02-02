class CategoryModel {
  final String id;
  final String name;

  CategoryModel({required this.id, required this.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    // 🔹 Extract ID securely - Handles malformed backend responses
    // Sometimes backend returns ID as: "[ new ObjectId('68da5e4f1a8695a0ad9309cb'), 'Health Care' ]"
    var rawId = json['_id'] ?? json['id'];
    String id = rawId?.toString() ?? '';

    // If ID looks like a stringified ObjectId array, extract the actual hex ID
    if (id.contains('ObjectId') && id.contains("'")) {
      final match = RegExp(r"ObjectId\('([a-fA-F0-9]+)'\)").firstMatch(id);
      if (match != null) {
        id = match.group(1) ?? id;
      }
    }

    return CategoryModel(id: id, name: json['name'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }

  @override
  String toString() => 'CategoryModel(id: $id, name: $name)';
}
