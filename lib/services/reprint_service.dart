import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/models/order.dart';
import 'package:mech_pos/models/printer_info.dart';
import 'package:mech_pos/services/order_service.dart';
import 'package:mech_pos/services/printer_service.dart';
import 'package:mech_pos/services/restaurant_service.dart';

class ReprintService {
  static Future<bool> reprintOrder({
    required String orderId,
    required PrinterInfo printer,
  }) async {
    try {
      // 1. Fetch restaurant info
      final restaurant =
          await RestaurantService.fetchRestaurantInfo();

      // 2. Fetch order by ID
      final Order order =
          await OrderService.fetchOrderById(orderId);

      // 3. Convert order items → CartItem format
      final List<CartItem> items = order.items.map((item) {
        return CartItem.fromReprint(
          name: item.name,
          quantity: item.qty,
          price: item.price,
        );
      }).toList();

      // 4. Print as DUPLICATE
      final didPrint = await PrinterService.printRestaurantBill(
        ip: printer.ip,
        port: printer.port,
        items: items,
        subtotal: order.subtotal,
        tax: order.tax,
        total: order.total,
        restaurant: restaurant,
        orderId: order.orderId,
        orderTime: order.createdAt,
        isReprint: true,
      );

      return didPrint;
    } catch (e) {
      return false;
    }
  }
}
