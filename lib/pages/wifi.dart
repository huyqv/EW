import 'package:flutter/material.dart';
import 'package:sample/base/base_state.dart';
import 'package:sample/const/color_res.dart';
import 'package:sample/utils/native.dart';

class WifiPage extends StatefulWidget {

  const WifiPage({Key? key}) : super(key: key);

  @override
  State<WifiPage> createState() => _WifiPageState();
}

class _WifiPageState extends BaseState<WifiPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.defaultBackgroundColor,
      body: Center(

      ),
    );
  }
}
