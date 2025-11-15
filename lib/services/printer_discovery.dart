import 'dart:io';

import 'package:mech_pos/models/printer_info.dart';

class PrinterDiscovery {
  /// Automatically find your subnet like "192.168.0"
  static Future<String> getSubnet() async {
    final interfaces = await NetworkInterface.list();

    for (final netInterface in interfaces) {
      for (final addr in netInterface.addresses) {
        if (addr.type == InternetAddressType.IPv4 &&
            !addr.isLoopback &&
            (addr.address.startsWith('192.') ||
             addr.address.startsWith('10.') ||
             addr.address.startsWith('172.'))) {
          final parts = addr.address.split('.');
          return '${parts[0]}.${parts[1]}.${parts[2]}';
        }
      }
    }

    return '192.168.0'; // fallback
  }

  /// Scan the subnet for reachable ESC POS printers on port 9100
  static Future<List<PrinterInfo>> scanPrinters({
    required String subnet,
    int port = 9100,
    Duration timeout = const Duration(milliseconds: 200),
  }) async {
    List<PrinterInfo> found = [];

    // Example subnet "192.168.0"
    // We scan 192.168.0.1 up to 192.168.0.254
    for (int i = 1; i <= 254; i++) {
      final ip = '$subnet.$i';

      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: timeout,
        );

        // If connect succeeds: printer exists
        await socket.close();
        found.add(PrinterInfo(ip, port));
      } catch (_) {
        // ignore failed addresses
      }
    }

    return found;
  }
}
