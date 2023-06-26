import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/home/home_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/member_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/time_line.dart';
import "package:collection/collection.dart";
import 'package:sample/utils/time.dart';

var _selectedAllProvider = StateProvider((ref) => false);
var _itemsSelectedProvider =
    StateProvider((ref) => List<Door>.empty(growable: true));
var _loadingProvider = StateProvider((ref) => false);

void showDialogHistory(BuildContext context, List<History> history) {
  var groupHistory = groupBy(history, (History obj) => obj.date());
  showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 500),
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40))),
      builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: SizedBox(
              height: height(context) * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border:
                            Border.all(color: Colors.transparent, width: 0.1),
                        color: ColorRes.gray),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Lịch sử ra vào cửa",
                    style: TextStyles.text24Bold(context),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Expanded(
                      child: history.isNotEmpty
                          ? ListView.builder(
                              itemCount: groupHistory.keys.length,
                              itemBuilder: (context, index) => HistoryBuilder(
                                    builder: (context, data, child) =>
                                        historyDarkItemWidget(context, data),
                                    data: groupHistory.values.elementAt(index),
                                    header: Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text(
                                        dateToString(history[0].time),
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
                            )),
                ],
              ),
            ),
          ));
}

void showDialogAction(
    {required BuildContext context,
    required Widget child,
    required String title,
    required String message,
    required String subMessage,
    required String actionText,
    required VoidCallback actionTap}) {
  showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 500),
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40))),
      builder: (context) => Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
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
                                color: Colors.transparent, width: 0.1),
                            color: ColorRes.gray),
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      child,
                      const SizedBox(
                        height: 40,
                      ),
                      Text(
                        title,
                        style: TextStyles.text24Bold(context),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                                text: message,
                                style: TextStyles.text14Gray(context)
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                children: [
                                  TextSpan(
                                      text: subMessage,
                                      style: TextStyles.text14Gray(context))
                                ])),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ButtonView(
                        text: actionText,
                        onTap: () {
                          actionTap();
                          Navigator.of(context).pop();
                        },
                      ),
                      ButtonView(
                        padding: const EdgeInsets.only(top: 16, bottom: 32),
                        text: 'Hủy bỏ',
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        textColor: ColorRes.primary,
                        borderColor: ColorRes.primary,
                        backgroundColor: Colors.white,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ));
}

void showDialogSelectDoor(BuildContext context) {
  showMaterialModalBottomSheet(
      context: context,
      duration: const Duration(milliseconds: 500),
      enableDrag: true,
      shape: const RoundedRectangleBorder(
          side: BorderSide(color: Colors.transparent),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40), topLeft: Radius.circular(40))),
      builder: (context) => const DoorListView());
}

class DoorListView extends BaseStatefulWidget {
  const DoorListView({Key? key}) : super(key: key);

  @override
  _DoorListViewState createState() => _DoorListViewState();
}

class _DoorListViewState extends BaseState<DoorListView> {
  late MemberVM _memberVM;
  late List<Door> _itemSelectVM;

  void _confirmClick(BuildContext context) async{
    ref.read(_loadingProvider.state).state = true;
    await _memberVM.setAccessMember();
    ref.read(_loadingProvider.state).state = false;
    pop(context);
    showTopAlert(context);
  }
  @override
  void initState() {
    _itemSelectVM = ref.read(_itemsSelectedProvider);
    _memberVM = ref.read(memberProvider);
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ref.read(_selectedAllProvider.state).state =
          _memberVM.doors.every((element) => element.isSelected);
      ref.read(_itemsSelectedProvider.state).state = _memberVM.doors;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
        child: SizedBox(
          height: height(context) * 0.8,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                left: 0,
                bottom: 56,
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 4,
                      margin: const EdgeInsets.only(top: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          border:
                              Border.all(color: Colors.transparent, width: 0.1),
                          color: ColorRes.gray),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Chọn cửa được ra vào",
                      style: TextStyles.text24Bold(context),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Consumer(builder: (context, ref, child) {
                      var doorList = ref.watch(_itemsSelectedProvider);
                      return Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              _doorAllItemWidget(context, doorList),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
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
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    child: Text(
                                      "CỬA RA VÀO",
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
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: doorList.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) =>
                                      _doorItemWidget(
                                          context, doorList[index])),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Consumer(
                  builder: (context, ref, child) => ref.watch(_loadingProvider)
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: ColorRes.primary,
                          ),
                        )
                      : ButtonView(
                          text: "Xác nhận",
                          onTap: () {
                            var status = ref.read(internetStatusProvider);
                            if(status != ConnectivityResult.none) {
                              _confirmClick(context);
                            } else {
                              toastInternetError(context);
                            }
                          },
                        ),
                ),
              )
            ],
          ),
        ));
  }

  Widget _doorAllItemWidget(BuildContext context, List<Door> doors) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: ColorRes.primaryLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.transparent)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Image.asset(
                ImageName.door,
                color: ColorRes.primary,
                width: 24,
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  "Tất cả (${doors.length})",
                  style: TextStyles.text14Bold(context),
                ),
              ),
            ],
          ),
          Consumer(
            builder: (context, ref, child) {
              var doors = ref.watch(_itemsSelectedProvider);
              var countItemSelected =
                  doors.where((element) => element.isSelected).length;
              return Row(
                children: [
                  Text(
                    countItemSelected != 0
                        ? "$countItemSelected được chọn"
                        : "",
                    style: TextStyles.text12Bold(context),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  appCheckBox(
                    isChecked:
                    doors.any((element) => element.isSelected),
                    checkedImage: ImageName.checkbox2,
                    paddingHorizontal: Dimen.padding8,
                    onCheckedChange: (check) {
                      ref.read(_selectedAllProvider.state).state = check;
                      ref.read(_itemsSelectedProvider.state).state =
                          doors.map((e) {
                        e.isSelected = check;
                        return e;
                      }).toList();
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _doorItemWidget(BuildContext context, Door door) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(12),
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
              Image.asset(
                ImageName.door,
                color: ColorRes.primary,
                width: 24,
                height: 24,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  door.getDisplayName(),
                  style: TextStyles.text14Bold(context),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Consumer(builder: (context, ref, child) {
              var doors = ref.watch(_itemsSelectedProvider);
              return appCheckBox(
                  isChecked: door.isSelected,
                  onCheckedChange: (check) {
                    ref.read(_itemsSelectedProvider.state).state =
                        doors.map<Door>((e) {
                      if (e.serial == door.serial) {
                        e.isSelected = check;
                      }
                      return e;
                    }).toList();
                  });
            }),
          )
        ],
      ),
    );
  }

  void showTopAlert(BuildContext context) {
    toastSuccess(context, "Đã cập nhật danh sách cửa ra vào thành công");
  }
}
