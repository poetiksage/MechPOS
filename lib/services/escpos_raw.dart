import 'dart:io';

import 'package:flutter/material.dart';

class EscPosRaw {
  static Future<bool> printData({
    required String ip,
    int port = 9100,
    required List<int> bytes,
  }) async {
    try {
      final socket = await Socket.connect(ip, port, timeout: Duration(seconds: 3));
      socket.add(bytes);
      await socket.flush();
      await socket.close();
      return true;
    } catch (e) {
      debugPrint("Printing failed: $e");
      return false;
    }
  }
}
