
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/const/color_res.dart';

void applyAppTheme(){
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: ColorRes.statusBarColor,
  ));
}

AppBar appBar(String title){
  return AppBar(
    title: Text(title),
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: ColorRes.statusBarColor,
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons)
      statusBarBrightness: Brightness.light, // For iOS (dark icons)
    ),
  );
}