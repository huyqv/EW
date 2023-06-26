import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';

import 'button.dart';

Widget buttonPrimary(
    {Color color = ColorRes.primary,
    required String text,
    required VoidCallback onPressed}) {
  return ButtonView(
    padding: const EdgeInsets.only(bottom: 24),
    text: text,
    onTap: onPressed,
  );
}
