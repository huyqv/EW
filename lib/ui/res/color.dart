import 'package:flutter/material.dart';

MaterialColor createMaterialColor(int value) {
  Color color = Color(value);
  List strengths = <double>[.05];
  final swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

class ColorRes {
  ColorRes._();

  static MaterialColor white = createMaterialColor(0xFFFFFFFF);
  static const Color statusBarColor = Colors.white;
  static const Color defaultBackgroundColor = Colors.white;
  static const Color primary = Color(0xFF014BDC);
  static const Color primaryDark = Color(0xFF0060AD);
  static const Color black = Color(0xFF000000);
  static const Color primaryLight = Color(0xFFE3ECFF);
  static const Color disable = Color(0xFFB8B8B8);
  static const Color textDefault = Color(0xFF323232);
  static const Color primaryBlack = Color(0xFF051D3F);
  static const Color gray = Color(0xFFB8B8B8);
  static const Color middleGray = Color(0xFF687E9D);
  static const Color lightGray = Color(0xFFF5F8FE);
  static const Color colorDisable =Color(0xFFE3E9F2);
  static const Color red = Color(0xFFCB2600);
  static const Color redLight = Color(0xFFFFF1EF);
  static const Color secondPrimary = Color(0xFF46D0FC);
  static const Color border = Color(0xFFBDCADD);

}
