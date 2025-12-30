import 'package:mech_pos/models/cart_item.dart';

class MenuItem implements PrintableItem {
  final int id;

  @override
  final String name;

  @override
  final double price;

  MenuItem({required this.id, required this.name, required this.price});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
