import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/image_view.dart';
import 'package:sample/ui/widgets/layout.dart';

void showDialogWarning({
  required BuildContext context,
  required History history,
}) {
  showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 500),
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(40),
            topLeft: Radius.circular(40),
          )),
      builder: (context) => Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 32,
            ),
            child: SizedBox(
              height: height(context) * 0.7,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: 45,
                        height: 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: Colors.transparent,
                            width: 0.1,
                          ),
                          color: ColorRes.gray,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Cảnh báo người lạ\nxuất hiện",
                        textAlign: TextAlign.center,
                        style: TextStyles.text24Bold(context),
                      ),
                    ],
                  ),
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                        width: 200,
                        height: 200,
                        child: ClipOval(
                          child: ImageView(image: history.image),
                        )),
                  ),
                  Column(
                    children: [
                      commonItemWidget(
                          context: context,
                          title: "Người lạ",
                          prefixIcon: ImageName.user,
                          backgroundColor: ColorRes.lightGray,
                          textStyle: TextStyles.text14(context)
                              ?.copyWith(fontWeight: FontWeight.w600),
                          onTap: () {}),
                      const SizedBox(
                        height: 16,
                      ),
                      commonItemWidget(
                          context: context,
                          title:
                              "${history.timeToString()} - ${history.date()}",
                          prefixIcon: ImageName.calendar,
                          backgroundColor: ColorRes.lightGray,
                          textStyle: TextStyles.text14(context)
                              ?.copyWith(fontWeight: FontWeight.w600),
                          onTap: () {})
                    ],
                  )
                ],
              ),
            ),
          ));
}
