import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/user/dialog.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/vm/member_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/image_view.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/time_line.dart';
import 'package:sample/utils/time.dart';

class MemberInfoPage extends BaseStatefulWidget {
  const MemberInfoPage({
    Key? key,
  }) : super(key: key);

  @override
  _MemberInfoState createState() => _MemberInfoState();
}

class _MemberInfoState extends BaseState<MemberInfoPage> {
  late HomeVM _homeVM;
  late MemberVM _memberVM;

  @override
  Widget build(BuildContext context) {
    _homeVM = ref.read(homeProvider);
    _memberVM = ref.read(memberProvider);
    _memberVM.member = _homeVM.selectedMember;
    _memberVM.filterDooCanAccess(_homeVM.selectedMember!.userId);
    _memberVM.listenDoorList();
    _memberVM.filterMemberHistory();

    return Consumer(builder: (context, ref, child) {
      ref.watch(memberProvider);
      if (_memberVM.member != null) {
        return Scaffold(
          body: SizedBox(
            height: height(context),
            child: ColoredBox(
              color: ColorRes.lightGray,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: height(context) * 0.55,
                      child: Stack(children: [
                        Positioned(
                          top: 0,
                          bottom: 100,
                          left: 0,
                          right: 0,
                          child: Image.asset(
                            ImageName.backgroundProfile1,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  widgetAppBar(
                                      context: context,
                                      backgroundColor: Colors.transparent,
                                      leftWidget: backWidget(context,
                                          color: Colors.white),
                                      centerWidget:
                                          euroLogoWidget(color: Colors.white),
                                      systemOverlayStyle:
                                          SystemUiOverlayStyle.light,
                                      actions: [
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                right: 24),
                                            child: GestureDetector(
                                                onTap: () {
                                                  _showDialogDeleteUser(
                                                      context, ref);
                                                },
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 24,
                                                )))
                                      ]),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24),
                                    child: Text(
                                      "Thông tin cá nhân",
                                      style:
                                          TextStyles.text24WhiteBold(context),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 24,
                          right: 24,
                          child: Column(
                            children: [
                              SizedBox(
                                width: 210,
                                height: 226,
                                child: Stack(children: [
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: SizedBox(
                                      width: 210,
                                      height: 210,
                                      child: ClipOval(
                                        child: ImageView(
                                          image: _memberVM.member!.userPhoto,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Consumer(
                                          builder: (context, ref, child) {
                                        ref.watch(memberProvider);
                                        return Image.asset(
                                          (_memberVM.member?.isBlocked ?? false)
                                              ? ImageName.lockCircle
                                              : ImageName.status,
                                          width: 32,
                                          height: 32,
                                        );
                                      })),
                                ]),
                              ),
                            ],
                          ),
                        )
                      ]),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: commonItemWidget(
                          context: context,
                          title: _memberVM.member!.userName,
                          prefixIcon: ImageName.user,
                          backgroundColor: ColorRes.white,
                          textStyle: TextStyles.text14(context)
                              ?.copyWith(fontWeight: FontWeight.w600),
                          margin: const EdgeInsets.only(top: 32, bottom: 16),
                          onTap: () {}),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24, right: 24),
                      child: Consumer(
                        builder: (context, ref, child) {
                          var _vm = ref.watch(memberProvider);
                          var number = _vm.doorsAccepted.length;
                          return commonItemWidget(
                              context: context,
                              title: "Cửa được ra vào ($number cửa)",
                              prefixIcon: ImageName.door,
                              suffixIcon: ImageName.dropDown,
                              backgroundColor: ColorRes.white,
                              textStyle: TextStyles.text14(context)
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              onTap: () {
                                if (_vm.doors.isNotEmpty) {
                                  showDialogSelectDoor(context);
                                } else {
                                  toastError(context,
                                      "Không lấy được danh sách cửa, vui lòng thử lại!");
                                }
                              });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Text(
                        "Lịch sử hoạt động",
                        style: TextStyles.text16Bold(context),
                      ),
                    ),
                    Consumer(builder: (context, ref, child) {
                      var histories = ref.watch(memberProvider).histories;
                      var groupHistory =
                          groupBy(histories, (History obj) => obj.date());
                      return histories.isNotEmpty
                          ? ListView.builder(
                              itemCount: groupHistory.keys.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) => HistoryBuilder(
                                    builder: (context, data, child) =>
                                        historyDarkItemWidget(context, data),
                                    data: groupHistory.values.elementAt(index),
                                    header: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        dateToString(groupHistory.values
                                            .elementAt(index)
                                            .elementAt(0)
                                            .time),
                                        style: TextStyles.text14Bold(context)
                                            ?.copyWith(
                                                color: ColorRes.middleGray),
                                      ),
                                    ),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                  ))
                          : Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: historyEmptyWidget(context, true),
                            );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: ColorRes.primary,
          ),
        );
      }
    });
  }

  void _showDialogDeleteUser(BuildContext context, WidgetRef ref) {
    showDialogAction(
        context: context,
        child: Image.asset(
          ImageName.trash,
          height: 90,
          width: 90,
        ),
        title: "Xóa tài khoản",
        message:
            "Tài khoản sẽ bị xóa vĩnh viễn và mất quyền ra vào tất cả các cửa.",
        subMessage: " Bạn có chắc chắn muốn xóa?",
        actionText: "Xóa tài khoản",
        actionTap: () async {
          await _memberVM.deleteMember();
          pop(context);
          userTopAlert(
              context,
              _homeVM.selectedMember!.userPhoto,
              ImageName.done,
              "Đã xóa thành công",
              "Đã xóa ${_homeVM.selectedMember!.userName} ra khỏi danh sách");
        });
  }

  void _showDialogLockUser(BuildContext context, WidgetRef ref) {
    showDialogAction(
        context: context,
        child: Image.asset(
          ImageName.lock,
          color: ColorRes.red,
          height: 90,
          width: 90,
        ),
        title: "Khóa tài khoản",
        message: "Tài khoản sẽ bị khóa tạm thời và không còn quyền ra vào cửa.",
        subMessage: " Bạn có chắc chắn muốn khóa?",
        actionText: "Khóa tài khoản",
        actionTap: () async {
          await _memberVM.setBlockMember();
          userTopAlert(
              context,
              _homeVM.selectedMember!.userPhoto,
              ImageName.done,
              "Đã khóa thành công",
              "${_homeVM.selectedMember!.userName} không còn quyền ra vào cửa");
        });
  }

  void _showDialogUnLockUser(BuildContext context, WidgetRef ref) {
    showDialogAction(
        context: context,
        child: Image.asset(
          ImageName.unlock,
          height: 90,
          width: 90,
        ),
        title: "Mở khóa tài khoản",
        message: "Tài khoản sẽ được kích hoạt và có quyền ra vào cửa.",
        subMessage: " Bạn có chắc chắn muốn mở khóa?",
        actionText: "Mở khóa tài khoản",
        actionTap: () async {
          await _memberVM.setBlockMember();
          userTopAlert(
              context,
              _homeVM.selectedMember!.userPhoto,
              ImageName.done,
              "Đã mở khóa thành công",
              "${_homeVM.selectedMember!.userName} có quyền ra vào cửa");
        });
  }
}
