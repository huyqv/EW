import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/image_view.dart';
import 'package:sample/ui/widgets/top_alert.dart';

import '../res/color.dart';
import '../res/image_name.dart';

mixin BaseView {
  OverlayEntry? _overlayEntry;

  Widget consumer(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        //ref.watch(provider);
        return Container(color: Colors.transparent);
      },
    );
  }

  double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  void alert(String message) {}

  void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  void topAlert(BuildContext context, Widget icon, Widget child,
      {Color backgroundColor = Colors.white,
      Color borderColor = ColorRes.primary,
      int durationAnim = 800,
      int delayCancelAnim = 2000}) {
    if (_overlayEntry != null) {
      return;
    }
    var overlay = OverlayEntry(builder: (BuildContext context) {
      return TopAlert(
        icon: icon,
        child: child,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        durationAnim: durationAnim,
        delayCancelAnim: delayCancelAnim,
      );
    });
    _overlayEntry = overlay;
    Navigator.of(context).overlay?.insert(overlay);
    Future.delayed(const Duration(seconds: 5), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void userTopAlert(BuildContext context, String image, String actionIcon,
      String title, String message,
      {bool isError = false}) {
    topAlert(
        context,
        SizedBox(
            width: 40,
            height: 40,
            child: ClipOval(
              child: ImageView(image: image),
            )),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  actionIcon,
                  width: 18,
                  height: 18,
                ),
                const SizedBox(
                  width: 4,
                ),
                Text(
                  title,
                  style: TextStyles.text14Bold(context),
                )
              ],
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              message,
              style: TextStyles.text14(context),
            )
          ],
        ),
        backgroundColor: isError ? ColorRes.redLight : ColorRes.white,
        borderColor: isError ? ColorRes.red : ColorRes.primary);
  }

  void toastSuccess(BuildContext context, String message) {
    topAlert(
      context,
      Container(
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: Image.asset(
          ImageName.done,
          width: 18,
          height: 18,
        ),
      ),
      Text(message, style: TextStyles.text14(context)),
      backgroundColor: ColorRes.primaryLight,
    );
  }

  void toastError(BuildContext context, String message, {String? icon}) {
    topAlert(
        context,
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(
            icon ?? ImageName.error,
            width: 18,
            height: 18,
          ),
        ),
        Text(message, style: TextStyles.text14(context)),
        backgroundColor: ColorRes.redLight,
        borderColor: ColorRes.red);
  }

  void toastInternetError(BuildContext context) {
    topAlert(
        context,
        Container(
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: Image.asset(
            ImageName.wifiDisconnect,
            width: 18,
            height: 18,
          ),
        ),
        Text("Mạng Wi-fi không khả dụng, vui lòng kiểm lại kết nối.",
            style: TextStyles.text14(context)),
        backgroundColor: ColorRes.redLight,
        borderColor: ColorRes.red,
        durationAnim: 1000,
        delayCancelAnim: 3000);
  }

  void toastActionDoorSuccess(
      BuildContext context, String title, String message) {
    topAlert(
      context,
      SizedBox(
        height: 40,
        width: 40,
        child: CircleAvatar(
          backgroundImage: AssetImage(ImageName.doorCircle),
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                ImageName.done,
                width: 18,
                height: 18,
              ),
              const SizedBox(
                width: 4,
              ),
              Text(title, style: TextStyles.text14Bold(context)),
            ],
          ),
          const SizedBox(
            height: 4,
          ),
          Text(message, style: TextStyles.text14(context)),
        ],
      ),
      backgroundColor: ColorRes.primaryLight,
    );
  }

  Widget progressView() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorRes.primary),
      ),
    );
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

  Widget padding({
    double left = .0,
    double top = .0,
    double right = .0,
    double bottom = .0,
    double vertical = .0,
    double horizontal = .0,
    double all = .0,
    Widget? child,
  }) {
    double firstLeft = left > 0 ? left : (horizontal > 0 ? horizontal : all);
    double firstRight = right > 0 ? right : (horizontal > 0 ? horizontal : all);
    double firstTop = top > 0 ? top : (vertical > 0 ? vertical : all);
    double firstBottom = bottom > 0 ? bottom : (vertical > 0 ? vertical : all);
    return Padding(
      padding: EdgeInsets.only(
        left: firstLeft,
        right: firstRight,
        top: firstTop,
        bottom: firstBottom,
      ),
      child: child,
    );
  }
}
