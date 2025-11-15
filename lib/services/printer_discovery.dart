import 'dart:io';

import 'package:mech_pos/models/printer_info.dart';

class PrinterDiscovery {
  static Future<List<PrinterInfo>> scanPrinters({
    required String subnet,
    int port = 9100,
    Duration timeout = const Duration(milliseconds: 500),
  }) async {
    final List<PrinterInfo> found = [];

    // Correct API for your version
    final stream = discover(
      subnet,
      port,
      timeout: timeout,
    );

    await for (final addr in stream) {
      if (addr.exists) {
        found.add(PrinterInfo(addr.ip, port));
      }
    }

    return found;
  }

  static Future<String> getSubnet() async {
    try {
      final interfaces = await NetworkInterface.list();

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 &&
              !addr.isLoopback &&
              (addr.address.startsWith('192.') ||
               addr.address.startsWith('10.') ||
               addr.address.startsWith('172.'))) {

            final parts = addr.address.split('.');
            return "${parts[0]}.${parts[1]}.${parts[2]}";
          }
        }
      }
    } catch (_) {}

    return "192.168.0";
  }
}
