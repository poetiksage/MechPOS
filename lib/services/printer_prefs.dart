import 'package:mech_pos/models/printer_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterPrefs {
  static const _keyIp = "printer_ip";
  static const _keyPort = "printer_port";

  static Future<void> savePrinter(PrinterInfo printer) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyIp, printer.ip);
    await prefs.setInt(_keyPort, printer.port);
  }

  static Future<PrinterInfo?> getSavedPrinter() async {
    final prefs = await SharedPreferences.getInstance();

    final ip = prefs.getString(_keyIp);
    final port = prefs.getInt(_keyPort);

    if (ip == null || port == null) return null;

    return PrinterInfo(ip, port);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIp);
    await prefs.remove(_keyPort);
  }
}
