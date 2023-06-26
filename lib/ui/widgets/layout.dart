import 'package:flutter/material.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/image_view.dart';

Widget defaultScaffold({
  Color backgroundColor = ColorRes.defaultBackgroundColor,
  required Widget child,
}) {
  return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: child,
      ));
}

double width(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

double height(BuildContext context) {
  return MediaQuery.of(context).size.height;
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

Widget goneView() {
  return const SizedBox(width: 0.0, height: 0.0);
}

Widget appCheckBox({
  double paddingLeft = .0,
  double paddingTop = .0,
  double paddingRight = .0,
  double paddingBottom = .0,
  double paddingVertical = .0,
  double paddingHorizontal = .0,
  double paddingAll = .0,
  String defaultImage = 'assets/images/checkbox.png',
  String checkedImage = 'assets/images/checkbox1.png',
  bool checkable = true,
  required bool isChecked,
  Function(bool isCheck)? onCheckedChange,
}) {
  String image;
  if (isChecked) {
    image = checkedImage;
  } else {
    image = defaultImage;
  }
  var checkBoxImage = padding(
    left: paddingLeft,
    top: paddingTop,
    right: paddingRight,
    bottom: paddingBottom,
    horizontal: paddingHorizontal,
    vertical: paddingVertical,
    all: paddingAll,
    child: Image.asset(
      image,
      width: Dimen.checkBoxSize,
      height: Dimen.checkBoxSize,
    ),
  );
  if (checkable) {
    return GestureDetector(
      child: checkBoxImage,
      onTap: () {
        onCheckedChange?.call(!isChecked);
      },
    );
  }
  return checkBoxImage;
}

Widget sloganBottomWidget(
  BuildContext context, {
  EdgeInsetsGeometry padding = EdgeInsets.zero,
}) {
  return ColoredBox(
    color: Colors.white,
    child: Padding(
      padding: padding,
      child: Column(
        children: [
          const SizedBox(height: Dimen.padding24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "created with",
                style: TextStyles.text10(context)
                    ?.copyWith(color: ColorRes.primaryBlack.withOpacity(0.5)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, right: 4),
                child: Image.asset(
                  ImageName.heart,
                  height: 10,
                  width: 10,
                ),
              ),
              Text(
                "by",
                style: TextStyles.text10(context)
                    ?.copyWith(color: ColorRes.primaryBlack.withOpacity(0.5)),
              ),
              Image.asset(
                ImageName.logoText,
                height: 16,
                width: 68,
              )
            ],
          ),
          const SizedBox(height: Dimen.padding16)
        ],
      ),
    ),
  );
}

Widget fullStack({required Widget child}) {
  return Positioned(
    top: 0,
    bottom: 0,
    left: 0,
    right: 0,
    child: child,
  );
}

Future<dynamic> push(BuildContext context, Widget widget) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

Widget historyLightItemWidget(BuildContext context, History history) {
  return Padding(
    padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
    child: Row(
      children: [
        SizedBox(
            height: 42,
            width: 42,
            child: ClipOval(
              child: ImageView(image: history.image,),
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.dateTimeToString(),
                  style: TextStyles.text12(context)
                      ?.copyWith(color: ColorRes.primaryLight),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text: history.userObj?.userName ?? "Unknown",
                        style: TextStyles.text14WhiteBold(context),
                        children: [
                          TextSpan(
                              text:
                                  "${history.statusToString()}${history.doorObj?.getDisplayName()}",
                              style: TextStyles.text14White(context))
                        ]),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget historyDarkItemWidget(BuildContext context, History history) {
  return Padding(
    padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
    child: Row(
      children: [
        SizedBox(
            height: 42,
            width: 42,
            child: ClipOval(
              child: ImageView(image: history.image,),
            )),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  history.timeToString(),
                  style: TextStyles.text12(context)
                      ?.copyWith(color: ColorRes.middleGray),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                        text:
                            "${history.userObj?.userName ?? "Unknown"}${history.statusToString()}",
                        style: TextStyles.text14(context),
                        children: [
                          TextSpan(
                              text: history.doorObj?.getDisplayName(),
                              style: TextStyles.text14Bold(context))
                        ]),
                  ),
                )
              ],
            ),
          ),
        )
      ],
    ),
  );
}

Widget historyWarningDarkItemWidget(BuildContext context,
    {required VoidCallback onTap, required History history}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(left: 24, top: 12, bottom: 12),
      child: Row(
        children: [
          SizedBox(
              height: 42,
              width: 42,
              child:ClipOval(
                child: ImageView(image: history.image,),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.timeToString(),
                    style: TextStyles.text12(context)
                        ?.copyWith(color: ColorRes.middleGray),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: history.userObj == null ? "Đang có người lạ ở trước cửa "
                              : "${history.userObj?.userName ?? "Unknown"} không vào được ",
                          style: TextStyles.text14(context),
                          children: [
                            TextSpan(
                                text: history.doorObj?.getDisplayName(),
                                style: TextStyles.text14Bold(context))
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_sharp,
            size: 12,
          )
        ],
      ),
    ),
  );
}

Widget historyWarningLightItemWidget(BuildContext context,
    {required VoidCallback onTap, required History history}) {
  return GestureDetector(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 12, bottom: 12),
      child: Row(
        children: [
          SizedBox(
              height: 42,
              width: 42,
              child: ClipOval(
                child: ImageView(image: history.image,),
              )),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    history.dateTimeToString(),
                    style: TextStyles.text12White(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: RichText(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                          text: history.userObj == null ? "Đang có người lạ ở trước cửa "
                              : "${history.userObj?.userName ?? "Unknown"} không vào được ",
                          style: TextStyles.text14White(context),
                          children: [
                            TextSpan(
                                text: history.doorObj?.getDisplayName(),
                                style: TextStyles.text14WhiteBold(context))
                          ]),
                    ),
                  )
                ],
              ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_sharp,
            size: 12,
            color: Colors.white,
          )
        ],
      ),
    ),
  );
}

Widget commonItemWidget({
  required BuildContext context,
  String? prefixIcon,
  String? suffixIcon,
  required String title,
  required VoidCallback onTap,
  EdgeInsetsGeometry? margin,
  Color borderColor = Colors.transparent,
  Color backgroundColor = Colors.white,
  TextStyle? textStyle,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 50,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 16, right: 16),
      margin: margin,
      decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (prefixIcon != null)
                Image.asset(
                  prefixIcon,
                  width: 24,
                  height: 24,
                  color: ColorRes.primary,
                ),
              Padding(
                padding: const EdgeInsets.only(left: 8, right: 8),
                child: Text(
                  title,
                  style: textStyle ?? TextStyles.text14(context),
                ),
              )
            ],
          ),
          if (suffixIcon != null)
            Image.asset(
              suffixIcon,
              width: 24,
              height: 24,
            ),
        ],
      ),
    ),
  );
}

Widget historyEmptyWidget(BuildContext context, isDark) {
  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Image.asset(
          isDark ? ImageName.actionDark : ImageName.action,
          width: 160,
          height: 160,
          fit: BoxFit.cover,
        ),
      ),
    ),
    Center(
      child: Text(
        "Chưa có hoạt động",
        style: TextStyles.text24WhiteBold(context)
            ?.copyWith(color: isDark ? ColorRes.primary : Colors.white),
      ),
    ),
    Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 16),
        child: Text(
          "Lịch sử sẽ hiển thị khi có lượt ra vào cửa",
          style: TextStyles.text14White(context)
              ?.copyWith(color: isDark ? ColorRes.middleGray : Colors.white),
        ),
      ),
    ),
  ]);
}
