import 'package:mech_pos/models/menu_item.dart';

class MenuCategory {
  final String categoryName;
  final List<MenuItem> items;

  MenuCategory({required this.categoryName, required this.items});

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      categoryName: json['category_name'],
      items: (json['items'] as List)
          .map((item) => MenuItem.fromJson(item))
          .toList(),
    );
  }
}
