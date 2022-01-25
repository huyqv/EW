
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/utils/color_res.dart';

void applyAppTheme(){
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorRes.statusBarColor,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.dark, // For iOS (dark icons)
  ));
}

Widget defaultPageLayout({required Widget child}) {
  return Scaffold(
      backgroundColor: ColorRes.defaultBackgroundColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: child,
      ));
}


