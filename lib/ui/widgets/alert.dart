import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';

mixin Alert {

  Future<void> alertMessage(
    BuildContext context, {
    bool barrierDismissible = false, // user can dismiss when touch outside
    Image? icon,
    String title = "",
    required String message,
    String button1Label = "Close",
    VoidCallback? button1OnPress,
    String button2Label = "",
    VoidCallback? button2OnPress,
  }) async {
    List<Widget> list = [];

    if (icon != null) {
      list.add(Padding(
        padding: const EdgeInsets.only(top: Dimen.padding16),
        child: icon,
      ));
    }
    if (title.isNotEmpty) {
      list.add(Padding(
        padding: const EdgeInsets.only(top: Dimen.padding16),
        child: Text(
          title,
          style: const TextStyle(color: ColorRes.textDefault),
        ),
      ));
    }
    list.add(Padding(
      padding: const EdgeInsets.only(top: Dimen.padding16),
      child: Text(
        message,
        style: const TextStyle(color: ColorRes.textDefault),
      ),
    ));
    if (button1Label.isNotEmpty) {
      list.add(
        MaterialButton(
          color: ColorRes.primary,
          child: Text(
            button1Label,
            style: const TextStyle(color: Colors.white),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            if(button1OnPress!=null){
              button1OnPress.call();
            }
          },
        ),
      );
    }
    if (button2Label.isNotEmpty) {
      list.add(
        MaterialButton(
          color: Colors.transparent,
          child: Text(
            button2Label,
            style: const TextStyle(color: ColorRes.textDefault),
          ),
          onPressed: () {
            Navigator.of(context).pop();
            if(button2OnPress!=null){
              button2OnPress.call();
            }
          },
        ),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Container(
          height: 300.0,
          width: 300.0,
          padding: const EdgeInsets.all(Dimen.padding16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: list,
          ),
        ),
      ),
    );
  }

}
