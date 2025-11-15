class PrinterInfo {
  final String ip;
  final int port;

  PrinterInfo(this.ip, this.port);

  @override
  String toString() => '$ip:$port';
}
