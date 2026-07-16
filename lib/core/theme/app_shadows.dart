import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x14000000), // 0.08 opacity (0.08 * 255 ≈ 20 => 0x14)
      offset: Offset(0, 8),
      blurRadius: 24,
    ),
  ];

  static const List<BoxShadow> floatingButton = [
    BoxShadow(
      color: Color(0x1E000000), // 0.12 opacity (0.12 * 255 ≈ 30 => 0x1E)
      offset: Offset(0, 12),
      blurRadius: 32,
    ),
  ];
}
