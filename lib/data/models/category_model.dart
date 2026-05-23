class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.isActive,
    this.iconUrl,
  });

  final String id;
  final String name;
  final String slug;
  final bool isActive;
  final String? iconUrl;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      isActive: json['is_active'] == true,
      iconUrl: json['icon_url']?.toString(),
    );
  }
}
