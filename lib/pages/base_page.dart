import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/widgets/progress.dart';

abstract class BasePage extends ConsumerWidget {
  BasePage({Key? key}) : super(key: key);

  /// Progress widget
  ProgressDialog? progressDialog;

  void showProgress(BuildContext context) {
    if (progressDialog == null) {
      progressDialog = ProgressDialog();
      Navigator.of(context).push(progressDialog!).then((value) {
        progressDialog = null;
      });
    }
  }

  void hideProgress() {
    if (progressDialog != null && progressDialog?.isActive == true) {
      progressDialog = null;
    }
  }

  void alert(String message) {}

  /// Navigation
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
