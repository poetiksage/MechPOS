import '../models/cart_item.dart';
import '../models/order.dart';
import 'api_client.dart';

class OrderService {
  static Future<void> createOrder({
    required String orderId,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
  }) async {
    await ApiClient.post('/order.php', {
      'order_id': orderId,
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'items': items
          .map(
            (c) => {
              'name': c.item.name,
              'qty': c.quantity,
              'price': c.item.price,
            },
          )
          .toList(),
    });
  }

  static Future<Order> fetchOrderById(String orderId) async {
    final response = await ApiClient.get('/order_fetch.php?order_id=$orderId');

    return Order.fromJson(response['data']);
  }
}
