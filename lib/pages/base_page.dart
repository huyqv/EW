import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/utils/color_res.dart';
import 'package:sample/widgets/progress.dart';

//ignore: must_be_immutable
abstract class BasePage extends ConsumerWidget with ProgressWidget {

  BasePage({Key? key}) : super(key: key);

  void alert(String message) {}

  Widget defaultScaffold({required Widget child}) {
    return Scaffold(
        backgroundColor: ColorRes.defaultBackgroundColor,
        body: SafeArea(
          top: true,
          bottom: true,
          child: child,
        ));
  }

  void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  Future<dynamic> push(BuildContext context, Widget widget) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<dynamic> pushAndRemove(BuildContext context, Widget widget) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
          (Route<dynamic> route) => false,
    );
  }


}
