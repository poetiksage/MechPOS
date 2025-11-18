import 'package:flutter/foundation.dart';
import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/services/escpos_commands.dart';
import 'package:mech_pos/services/escpos_raw.dart';

class PrinterService {
  static Future<bool> printRestaurantBill({
    required String ip,
    required int port,
    required List<CartItem> items,
    required double subtotal,
    required double tax,
    required double total,
  }) async {
    final List<int> bytes = [];

    try {
      // Build your ESC POS bytes here
      bytes.addAll(EscPosCommands.init());
      bytes.addAll(EscPosCommands.alignCenter());
      bytes.addAll(EscPosCommands.boldOn());
      bytes.addAll(EscPosCommands.text("Restaurant Bill"));
      bytes.addAll(EscPosCommands.boldOff());
      bytes.addAll(EscPosCommands.alignLeft());

      for (final c in items) {
        bytes.addAll(
          EscPosCommands.text(
            "${c.item.name} x${c.quantity}   €${c.total.toStringAsFixed(2)}",
          ),
        );
      }

      bytes.addAll(EscPosCommands.text("-----------------------------"));
      bytes.addAll(
        EscPosCommands.text("Subtotal   €${subtotal.toStringAsFixed(2)}"),
      );
      bytes.addAll(
        EscPosCommands.text("Tax        €${tax.toStringAsFixed(2)}"),
      );
      bytes.addAll(
        EscPosCommands.text("Total      €${total.toStringAsFixed(2)}"),
      );
      bytes.addAll(EscPosCommands.cut());

      final ok = await EscPosRaw.printData(ip: ip, port: port, bytes: bytes);

      return ok; // <-- Return true or false
    } catch (e) {
      debugPrint("Print error: $e");
      return false;
    }
  }
}
