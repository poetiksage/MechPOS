

/// Common contract for anything that can appear on a receipt
abstract class PrintableItem {
  String get name;
  double get price;
}

/// Cart item used for both normal orders and reprints
class CartItem {
  final PrintableItem item;
  int quantity;

  CartItem({
    required this.item,
    required this.quantity,
  });

  double get total => item.price * quantity;

  /// Constructor used when reprinting an order from DB
  CartItem.fromReprint({
    required String name,
    required int quantity,
    required double price,
  })  : item = ReprintMenuItem(name: name, price: price),
        quantity = quantity;
}

/// Lightweight item used only for reprints
class ReprintMenuItem implements PrintableItem {
  @override
  final String name;

  @override
  final double price;

  ReprintMenuItem({
    required this.name,
    required this.price,
  });
}
