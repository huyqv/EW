import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';

Widget defaultScaffold(
    {Color backgroundColor = ColorRes.defaultBackgroundColor,
    required Widget child}) {
  return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: child,
      ));
}
