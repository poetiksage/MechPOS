import 'package:mech_pos/models/cart_item.dart';
import 'package:mech_pos/services/escpos_commands.dart';
import 'package:mech_pos/services/escpos_raw.dart';

class PrinterService {
  static Future<void> printRestaurantBill({
  required String ip,
  int port = 9100,
  required List<CartItem> items,
  required double subtotal,
  required double tax,
  required double total,
}) async {
  final bytes = <int>[];

  // Initialize printer
  bytes.addAll(EscPosCommands.init());

  // Header
  bytes.addAll(EscPosCommands.alignCenter());
  bytes.addAll(EscPosCommands.boldOn());
  bytes.addAll(EscPosCommands.text("Restaurant Bill"));
  bytes.addAll(EscPosCommands.boldOff());
  bytes.addAll(EscPosCommands.text("--------------------------------"));

  // Items
  bytes.addAll(EscPosCommands.alignLeft());
  for (final cartItem in items) {
    final name = cartItem.item.name;
    final qty = cartItem.quantity;
    final price = cartItem.item.price * qty;

    // Name line
    bytes.addAll(EscPosCommands.text("$name  x$qty"));

    // Price line aligned right
    bytes.addAll(EscPosCommands.text("      €${price.toStringAsFixed(2)}"));
  }

  bytes.addAll(EscPosCommands.text("--------------------------------"));

  // Summary
  bytes.addAll(EscPosCommands.text("Subtotal    €${subtotal.toStringAsFixed(2)}"));
  bytes.addAll(EscPosCommands.text("Tax         €${tax.toStringAsFixed(2)}"));
  bytes.addAll(EscPosCommands.text("Total       €${total.toStringAsFixed(2)}"));

  // Footer
  bytes.addAll(EscPosCommands.text("\nThank you"));
  bytes.addAll(EscPosCommands.text("Visit again soon"));
  bytes.addAll(EscPosCommands.text("\n\n"));

  // Cut paper
  bytes.addAll(EscPosCommands.cut());

  await EscPosRaw.printData(ip: ip, port: port, bytes: bytes);
}

}
