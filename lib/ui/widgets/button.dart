import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';
import 'layout.dart' as screen_size;
class ButtonView extends StatelessWidget {
  Color backgroundColor;

  Color borderColor;
  final String text;
  Color textColor;
  final int? theme;
  final void Function()? onTap;
  final double? width;
  final EdgeInsetsGeometry? padding;
  static const outline = 1;

  ButtonView({
    Key? key,
    this.backgroundColor = ColorRes.primary,
    this.textColor = Colors.white,
    this.theme,
    required this.text,
    required this.onTap,
    this.width,
    this.padding,
    this.borderColor = ColorRes.primary,
  }) : super(key: key);

  Timer? _debounceTime;

  @override
  Widget build(BuildContext context) {
    switch (theme) {
      case outline:
        backgroundColor = Colors.white;
        textColor = ColorRes.primary;
        borderColor = ColorRes.primary;
        break;
      default:
        break;
    }
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        height: 48,
        width: width ?? screen_size.width(context),
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              backgroundColor:
                  MaterialStateProperty.all<Color>(backgroundColor),
              elevation: MaterialStateProperty.all<double>(0),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      side: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(40)))),
          onPressed: () {
            if (onTap != null) {
              if (_debounceTime?.isActive ?? false) {
                _debounceTime?.cancel();
              }
              _debounceTime = Timer(const Duration(seconds: 1), () {
                onTap!();
              });
            }
          },
          child: Text(
            text,
            style: TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

class ButtonView2 extends StatelessWidget {
  final Color backgroundColor;
  final Color borderColor;
  final Widget child;
  final void Function()? onTap;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;

  const ButtonView2(
      {Key? key,
      this.backgroundColor = ColorRes.primary,
      required this.onTap,
      this.width,
      this.padding,
      this.borderColor = ColorRes.primary,
      required this.child,
      this.height = 56,
      this.borderRadius = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: width ?? screen_size.width(context),
        child: ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
              // overlayColor: MaterialStateProperty.all<Color>(ColorRes.primary),
              backgroundColor:
                  MaterialStateProperty.all<Color>(backgroundColor),
              elevation: MaterialStateProperty.all<double>(0),
              shape: MaterialStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                      side: BorderSide(color: borderColor),
                      borderRadius: BorderRadius.circular(borderRadius)))),
          onPressed: onTap,
          child: child,
        ),
      ),
    );
  }
}
