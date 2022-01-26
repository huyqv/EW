import 'package:flutter/material.dart';
import 'package:sample/utils/color_res.dart';

mixin ProgressWidget {
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
}

class ProgressDialog extends ModalRoute<void> {
  @override
  Duration get transitionDuration => const Duration(milliseconds: 1000);

  @override
  bool get opaque => false;

  @override
  bool get barrierDismissible => false;

  @override
  Color get barrierColor => Colors.white.withAlpha(0);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return TextButton(
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorRes.primary),
        ),
      ),
      onPressed: () => Navigator.pop(context),
    );
  }

}