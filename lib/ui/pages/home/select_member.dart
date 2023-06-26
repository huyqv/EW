import 'package:flutter/material.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/layout.dart';

class SelectMemberPage extends BaseStatefulWidget {
  const SelectMemberPage({Key? key}) : super(key: key);

  @override
  _SelectMemberPageState createState() => _SelectMemberPageState();
}

class _SelectMemberPageState extends BaseState<SelectMemberPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        appBar: widgetAppBar(context: context, centerWidget: euroLogoWidget()),
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 24, left: 24, right: 24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Chọn thành viên",
                            style: TextStyles.text24Bold(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16, bottom: 24),
                            child: Text(
                              "Danh sách thành viên đã đăng ký khuôn mặt",
                              style: TextStyles.text14Gray(context),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Row(
                              children: [
                                const Flexible(
                                  flex: 1,
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: ColorRes.middleGray,
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 8, right: 8),
                                  child: Text(
                                    "THÀNH VIÊN",
                                    style: TextStyles.text12Gray(context),
                                  ),
                                ),
                                const Flexible(
                                  flex: 1,
                                  child: Divider(
                                    height: 1,
                                    thickness: 1,
                                    color: ColorRes.middleGray,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: 10,
                              itemBuilder: (context, index) =>
                                  _memberItemWidget(context))
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ButtonView(
                      text: "Xác nhận",
                      onTap: () {},
                    ),
                    sloganBottomWidget(context),
                  ],
                ),
              )
            ]));
  }

  Widget _memberItemWidget(BuildContext context, {double iconSize = 32}) {
    return Container(
      height: 56,
      width: width(context),
      padding: const EdgeInsets.only(top: 12, bottom: 12, left: 16, right: 16),
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
          color: ColorRes.lightGray,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: CircleAvatar(
                  backgroundImage: AssetImage(ImageName.avatar),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16, right: 16),
                child: Text(
                  "Tất cả (5)",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyles.text14Bold(context),
                ),
              ),
            ],
          ),
          Checkbox(value: false, onChanged: (check) {}),
        ],
      ),
    );
  }
}
