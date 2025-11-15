class EscPosCommands {
  static const esc = 27;
  static const gs = 29;

  static List<int> init() => [esc, 64];

  static List<int> text(String text) =>
      [...text.codeUnits, 10]; // 10 = line break

  static List<int> boldOn() => [esc, 69, 1];
  static List<int> boldOff() => [esc, 69, 0];

  static List<int> alignCenter() => [esc, 97, 1];
  static List<int> alignLeft() => [esc, 97, 0];

  static List<int> cut() => [gs, 86, 1];
}
