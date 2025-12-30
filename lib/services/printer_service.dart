import 'package:flutter/foundation.dart';
import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/models/restaurant_info.dart';
import 'package:mech_pos/services/escpos_commands.dart';
import 'package:mech_pos/services/escpos_raw.dart';

class PrinterService {
  // 48 character two column helper
  static String twoCol(String left, String right, {int width = 48}) {
    final l = left.length;
    final r = right.length;
    final spaces = width - l - r;
    return left + " " * spaces + right;
  }

  // 48 character three column helper
  static String threeCol(
    String left,
    String middle,
    String right, {
    int width = 48,
  }) {
    final col1 = 22;
    final col2 = 8;
    final col3 = width - col1 - col2;

    final p1 = left.padRight(col1);
    final p2 = middle.padRight(col2);
    final p3 = right.padLeft(col3);

    return p1 + p2 + p3;
  }

  static Future<bool> printRestaurantBill({
    required String ip,
    required int port,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
    required RestaurantInfo restaurant,
    required String orderId,
    required DateTime orderTime,
    bool isReprint = false,
  }) async {
    final List<int> bytes = [];

    try {
      bytes.addAll(EscPosCommands.init());

      // Reprint banner
      if (isReprint) {
        bytes.addAll(EscPosCommands.alignCenter());
        bytes.addAll(EscPosCommands.boldOn());
        bytes.addAll(EscPosCommands.text("***** DUPLICATE *****"));
        bytes.addAll(EscPosCommands.boldOff());
        bytes.addAll(EscPosCommands.text(""));
        bytes.addAll(EscPosCommands.alignLeft());
      }

      bytes.addAll(EscPosCommands.alignLeft());
      bytes.addAll(EscPosCommands.text(twoCol("Order ID", orderId)));

      final formattedTime =
          "${orderTime.day.toString().padLeft(2, '0')}/"
          "${orderTime.month.toString().padLeft(2, '0')}/"
          "${orderTime.year} "
          "${orderTime.hour.toString().padLeft(2, '0')}:"
          "${orderTime.minute.toString().padLeft(2, '0')}";

      bytes.addAll(EscPosCommands.text(twoCol("Date", formattedTime)));
      bytes.addAll(
        EscPosCommands.text("----------------------------------------"),
      );

      // Header
      bytes.addAll(EscPosCommands.alignCenter());
      bytes.addAll(EscPosCommands.boldOn());
      bytes.addAll(EscPosCommands.text(restaurant.name));
      bytes.addAll(EscPosCommands.boldOff());

      if (restaurant.address.isNotEmpty) {
        bytes.addAll(EscPosCommands.text(restaurant.address));
      }

      if (restaurant.phone.isNotEmpty) {
        bytes.addAll(EscPosCommands.text("Tel: ${restaurant.phone}"));
      }

      bytes.addAll(EscPosCommands.text(""));
      bytes.addAll(EscPosCommands.boldOn());
      bytes.addAll(EscPosCommands.text("RESTAURANT BILL"));
      bytes.addAll(EscPosCommands.boldOff());
      bytes.addAll(EscPosCommands.text(""));
      bytes.addAll(EscPosCommands.alignLeft());

      // Top divider
      bytes.addAll(
        EscPosCommands.text("------------------------------------------------"),
      );

      // Column titles
      bytes.addAll(EscPosCommands.text(threeCol("Item", "Qty", "Price")));

      // Divider
      bytes.addAll(
        EscPosCommands.text("------------------------------------------------"),
      );

      // Items section
      for (final c in items) {
        final name = c.item.name;
        final qty = c.quantity.toString();
        final price = "€${c.total.toStringAsFixed(2)}";

        bytes.addAll(EscPosCommands.text(threeCol(name, qty, price)));
      }

      // Divider
      bytes.addAll(
        EscPosCommands.text("------------------------------------------------"),
      );

      // Totals
      bytes.addAll(
        EscPosCommands.text(
          twoCol("Subtotal", "€${subtotal.toStringAsFixed(2)}"),
        ),
      );
      bytes.addAll(
        EscPosCommands.text(twoCol("Tax", "€${tax.toStringAsFixed(2)}")),
      );
      bytes.addAll(EscPosCommands.boldOn());
      bytes.addAll(
        EscPosCommands.text(twoCol("TOTAL", "€${total.toStringAsFixed(2)}")),
      );
      bytes.addAll(EscPosCommands.boldOff());

      // Divider
      bytes.addAll(
        EscPosCommands.text("------------------------------------------------"),
      );

      // Footer
      bytes.addAll(EscPosCommands.alignCenter());

      if (restaurant.footerMessage.isNotEmpty) {
        bytes.addAll(EscPosCommands.text(restaurant.footerMessage));
      }

      bytes.addAll(EscPosCommands.text("Thank you"));
      bytes.addAll(EscPosCommands.text(""));

      // Full cut
      bytes.addAll(EscPosCommands.cut());

      // Print
      final ok = await EscPosRaw.printData(ip: ip, port: port, bytes: bytes);
      return ok;
    } catch (e) {
      debugPrint("Print error: $e");
      return false;
    }
  }
}
