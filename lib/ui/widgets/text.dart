import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';

Widget buttonPrimary(
    {Color color = ColorRes.primary,
    required String text,
    required VoidCallback onPressed}) {
  return MaterialButton(
    color: color,
    child: Text(text, style: const TextStyle(color: Colors.white)),
    onPressed: onPressed,
  );
}
