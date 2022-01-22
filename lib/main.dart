import 'package:flutter/material.dart';
import 'package:sample/const/ColorRes.dart';

import 'pages/home/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sample App',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: ColorRes.white,
      ),
      home: const HomePage(title: 'Flutter Demo Home Page'),
    );
  }
}
