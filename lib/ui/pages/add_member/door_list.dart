import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/door.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/add_member_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/layout.dart';

class DoorListView extends BaseStatefulWidget {
  const DoorListView({Key? key}) : super(key: key);

  @override
  _DoorListViewState createState() => _DoorListViewState();
}

class _DoorListViewState extends BaseState<DoorListView> {
  late AddMemberVM _addMemberVM;

  @override
  Widget build(BuildContext context) {
    _addMemberVM = ref.read(addMemberProvider);
    return WillPopScope(
      onWillPop: () async => false,
      child: Padding(
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
                    Consumer(
                      builder: (context, ref, child) {
                        ref.watch(addMemberProvider);
                        return child!;
                      },
                      child:  Expanded(
                        child: SingleChildScrollView(
                        child:Column(
                            children: [
                              _doorAllItemWidget(context, _addMemberVM.doors),
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
                                    padding: const EdgeInsets.only(left: 8, right: 8),
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
                                  itemCount: _addMemberVM.doors.length,
                                  padding: EdgeInsets.zero,
                                  itemBuilder: (context, index) => _doorItemWidget(
                                      context, _addMemberVM.doors[index])),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ButtonView(
                  text: "Xác nhận",
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
              return appCheckBox(
                checkedImage: ImageName.check3,
                isChecked: doors.every((element) => element.isSelected),
                onCheckedChange: (isChecked) {
                  _addMemberVM.onAllDoorSelected(isChecked);
                },
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
          Consumer(builder: (context, ref, child) {
            return appCheckBox(
              isChecked: door.isSelected,
              onCheckedChange: (isChecked) {
                _addMemberVM.onDoorSelected(door);
              },
            );
          })
        ],
      ),
    );
  }
}
