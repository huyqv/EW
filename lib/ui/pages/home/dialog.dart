import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/member.dart';
import 'package:sample/router/route_name.dart';
import 'package:sample/router/routing.dart';
import 'package:sample/ui/pages/add_member/add_member.dart';
import 'package:sample/ui/pages/add_member/member_list.dart';
import 'package:sample/ui/pages/door_name.dart';
import 'package:sample/ui/pages/door_select_wifi_page.dart';
import 'package:sample/ui/pages/door_warning.dart';
import 'package:sample/ui/pages/user/dialog.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/door_vm.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/dialog.dart';
import 'package:sample/ui/widgets/layout.dart';

void showHomeMenuDialog(
  BuildContext context,
  WidgetRef ref, {
  required VoidCallback onClose,
  required VoidCallback onOpenDoorTap,
}) {
  var dialog = showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 500),
      backgroundColor: ColorRes.white,
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(24), topLeft: Radius.circular(24))),
      builder: (context) =>
          Padding(
              padding: const EdgeInsets.only(top: 24, bottom: 24),
              child: SizedBox(
                width: width(context),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.start,
                  runAlignment: WrapAlignment.start,
                  alignment: WrapAlignment.start,
                  children: [
                _itemItemSettingWidget(
                  context,
                  title: 'Mở cửa',
                  icon: ImageName.route,
                  onTap: () {
                    onOpenDoorTap();
                  },
                ),
                /*_itemItemSettingWidget(
                  context,
                  title: 'Thành viên',
                  color: ColorRes.primary,
                  icon: ImageName.member,
                  onTap: () {
                    Routing.navigate2(
                      context,
                      (context) => MemberListPage(
                        door: ref.read(homeProvider).selectedDoor!,
                      ),
                      routeName: RouteName.memberListPage,
                    );
                  },
                ),*/
                _itemItemSettingWidget(
                  context,
                  title: 'Cảnh báo',
                  color: ColorRes.primary,
                  icon: ImageName.notification,
                  onTap: () {
                    var door = ref.read(homeProvider).selectedDoor!;
                    ref.read(doorWarningProvider.state).state = door.warning;
                    Routing.navigate2(
                      context,
                      (context) => DoorWarningPage(
                        door: door
                      ),
                      routeName: RouteName.doorWarning,
                    );
                  },
                ),
                _itemItemSettingWidget(
                  context,
                  title: 'Đổi tên',
                  icon: ImageName.edit,
                  onTap: () {
                    showBottomDialog(context, DoorNameDialog());
                  },
                ),
                _itemItemSettingWidget(
                  context,
                  title: 'Cài đặt Wifi',
                  icon: ImageName.wifi,
                  onTap: () {
                    Routing.navigate2(
                      context,
                      (context) => const DoorSelectWifiPage(),
                      routeName: RouteName.doorTutorial,
                    );
                  },
                ),
                _itemItemSettingWidget(
                  context,
                  title: 'Xóa cửa',
                  icon: ImageName.trash,
                  backgroundColor: ColorRes.redLight,
                  onTap: () {
                    showDialogRemoveDoor(context, ref);
                  },
                ),
              ],
            ),
          )));
  dialog.then((value) => onClose());
}

void showDialogRemoveDoor(BuildContext context, WidgetRef ref) {
  showDialogAction(
      context: context,
      child: Image.asset(
        ImageName.trash,
        height: 90,
        width: 90,
      ),
      title: "Xóa cửa",
      message: "Cửa ra vào sẽ bị xóa vĩnh viễn và mất kết nối với thiết bị.",
      subMessage: "Toàn bộ dữ liệu sẽ bị xóa, bạn có chắc chắn muốn xóa?",
      actionText: "Xóa cửa",
      actionTap: () {
        var homeVM = ref.read(homeProvider);
        ref.read(doorProvider).deleteDoor(homeVM.selectedDoor!,
            [...homeVM.allHistories, ...homeVM.allHistoriesWarning],
            onSuccess: () {}, onError: () {});
      });
}

void showDialogAddMember(
    BuildContext context, Door door, List<Member> members) {
  showMaterialModalBottomSheet(
      context: context,
      bounce: true,
      duration: const Duration(milliseconds: 500),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40))),
      builder: (context) => SizedBox(
            height: height(context) * 0.7,
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
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
                                color: Colors.transparent, width: 0.1),
                            color: ColorRes.gray),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Image.asset(
                        ImageName.addUser,
                        width: 90,
                        height: 90,
                        color: ColorRes.primary,
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Thêm thành viên",
                        style: TextStyles.text24Bold(context),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        "Vui lòng chọn thành viên được ra vào cửa",
                        style: TextStyles.text14Bold(context)
                            ?.copyWith(color: ColorRes.middleGray),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ButtonView(
                          text: "Chọn từ danh sách",
                          backgroundColor: members.isNotEmpty
                              ? ColorRes.primary
                              : ColorRes.colorDisable,
                          borderColor: members.isNotEmpty
                              ? ColorRes.primary
                              : ColorRes.colorDisable,
                          onTap: () {
                            if (members.isNotEmpty) {
                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                              Routing.navigate2(context,
                                  (context) => MemberListPage(door: door),
                                  routeName: RouteName.memberListPage);
                            }
                          }),
                      ButtonView(
                          padding: const EdgeInsets.only(top: 16, bottom: 16),
                          text: "Thêm mới thành viên",
                          textColor: ColorRes.primary,
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            }
                            Routing.navigate2(
                                context, (context) => const AddMemberPage(),
                                routeName: RouteName.addMember);
                          },
                          backgroundColor: Colors.white)
                    ],
                  )
                ],
              ),
            ),
          ));
}

Widget _itemItemSettingWidget(
  BuildContext context, {
  required String icon,
  required String title,
  required VoidCallback onTap,
  Color? color,
  Color? backgroundColor,
}) {
  Widget imageWidget;
  if (color != null) {
    imageWidget = Image.asset(
      icon,
      color: color,
      width: 24,
      height: 24,
    );
  } else {
    imageWidget = Image.asset(
      icon,
      width: 24,
      height: 24,
    );
  }
  return SizedBox(
    width: width(context) / 3,
    child: Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ButtonView2(
            onTap: () {
              Navigator.of(context).pop();
              onTap();
            },
            width: 56,
            backgroundColor: backgroundColor ?? ColorRes.primaryLight,
            borderColor: Colors.transparent,
            padding: const EdgeInsets.only(bottom: 8),
            borderRadius: 16,
            child: imageWidget,
          ),
          Text(
            title,
            style: TextStyles.text12Bold(context),
          )
        ],
        ),
    ),
  );
}




