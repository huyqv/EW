
import 'package:flutter/material.dart';
import 'package:sample/const/color_res.dart';
import 'package:sample/widgets/ui.dart';

import 'pages/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    applyAppTheme();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sample App',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: ColorRes.white,
      ),
      home: const HomePage(title: ''),
    );
  }
}
