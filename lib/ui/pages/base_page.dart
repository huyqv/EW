import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/widgets/alert.dart';
import 'package:sample/ui/widgets/permission.dart';
import 'package:sample/ui/widgets/progress.dart';

//ignore: must_be_immutable
abstract class BasePage extends ConsumerWidget
    with ProgressWidget,
        Alert,
        PermissionUtil {

  BasePage({Key? key}) : super(key: key);

  void alert(String message) {}

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
