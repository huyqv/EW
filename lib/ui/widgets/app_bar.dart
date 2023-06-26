import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';

import '../res/dimen.dart';

AppBar simpleAppBar(
    {required BuildContext context,
    bool isBack = true,
    String title = "",
    List<Widget>? actions,
    Color backgroundColor = Colors.white}) {
  return AppBar(
    toolbarHeight: 56,
    backgroundColor: backgroundColor,
    leading: (isBack)
        ? GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Icon(
              Icons.arrow_back_ios,
              size: 20,
              color: Colors.white,
            ),
          )
        : null,
    title: title.isNotEmpty
        ? Text(
            title,
            style: TextStyles.text14WhiteBold(context),
          )
        : null,
    actions: actions,
  );
}

AppBar widgetAppBar(
    {required BuildContext context,
    Widget? leftWidget,
    Widget? centerWidget,
    List<Widget>? actions,
    bool centerTitle = true,
    Color backgroundColor = Colors.transparent,
    systemOverlayStyle = SystemUiOverlayStyle.dark}) {
  return AppBar(
    elevation: 0,
    centerTitle: centerTitle,
    backgroundColor: backgroundColor,
    leading: leftWidget ?? backWidget(context),
    title: centerWidget ?? const SizedBox(),
    actions: actions,
    systemOverlayStyle: systemOverlayStyle,
  );
}

Widget backWidget(BuildContext context, {Color color = ColorRes.primaryBlack}) {
  return GestureDetector(
    onTap: () {
      Navigator.of(context).pop();
    },
    child: SizedBox(
      width: Dimen.appBarSize,
      height: Dimen.appBarSize,
      child: Icon(
        Icons.arrow_back_ios_outlined,
        size: 24,
        color: color,
      ),
    ),
  );
}

Widget backButtonDark(BuildContext context) {
  return backWidget(context, color: ColorRes.primaryBlack);
}

Widget backButtonLight(BuildContext context) {
  return backWidget(context, color: Colors.white);
}

Widget euroLogoWidget({Color? color}) {
  return Image.asset(
    ImageName.logoEuro,
    width: 114,
    height: 28,
    color: color,
  );
}

Widget logoDark() {
  return euroLogoWidget(color: ColorRes.primaryDark);
}

Widget logoLight() {
  return euroLogoWidget(color: Colors.white);
}
