class Order {
  final String orderId;
  final DateTime createdAt;
  final double subtotal;
  final double tax;
  final double total;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.createdAt,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      createdAt: DateTime.parse(json['created_at']),
      subtotal: double.parse(json['subtotal'].toString()),
      tax: double.parse(json['tax'].toString()),
      total: double.parse(json['total'].toString()),
      items: (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList(),
    );
  }
}

class OrderItem {
  final String name;
  final int qty;
  final double price;

  OrderItem({required this.name, required this.qty, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      name: json['item_name'],
      qty: int.parse(json['quantity'].toString()),
      price: double.parse(json['price'].toString()),
    );
  }
}
