import 'package:flutter/material.dart';
import 'package:sample/widgets/progress.dart';

abstract class BaseState<SW extends StatefulWidget> extends State<SW> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  ProgressDialog? progressDialog;

  void showProgress() {
    if (progressDialog == null) {
      progressDialog = ProgressDialog();
      Navigator.of(context).push(progressDialog!).then((value) {
        progressDialog = null;
      });
    }
  }

  void hideProgress() {
    if (progressDialog != null && progressDialog?.isActive == true) {
      pop();
      progressDialog = null;
    }
  }

  void alert(String message) {}

  void pop() {
    Navigator.of(context).pop();
  }

  Future<dynamic> push(Widget widget) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => widget),
    );
  }

  Future<dynamic> pushAndRemove(Widget widget) {
    return Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => widget),
      (Route<dynamic> route) => false,
    );
  }
}
