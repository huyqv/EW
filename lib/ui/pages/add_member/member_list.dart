import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/member.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/add_member_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/image_view.dart';
import 'package:sample/ui/widgets/layout.dart';

import '../../../utils/utils.dart';

class MemberListPage extends BaseStatefulWidget {
  const MemberListPage({Key? key, required this.door}) : super(key: key);
  final Door door;

  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends BaseState<MemberListPage> {
  late AddMemberVM _addMemberVM;

  @override
  Widget build(BuildContext context) {
    _addMemberVM = ref.read(addMemberProvider);
    _addMemberVM.getAccessMember(widget.door);
    return Scaffold(
      appBar: widgetAppBar(context: context, centerWidget: logoDark()),
      body: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: Column(children: [
          padding(bottom: Dimen.padding24),
          Text(
            "Chọn thành viên",
            style: TextStyles.text24Bold(context),
          ),
          padding(bottom: Dimen.padding16),
          Text(
            "Danh sách thành viên đã đăng ký khuôn mặt",
            style: TextStyles.text14Gray(context),
          ),
          padding(bottom: Dimen.padding32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(children: [
                _doorAllItemWidget(),
                padding(bottom: Dimen.padding16),
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
                Consumer(
                  builder: (context, ref, child) {
                    ref.watch(addMemberProvider);
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _addMemberVM.members.length,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) => _memberItemWidget(
                        context,
                        _addMemberVM.members[index],
                      ),
                    );
                  },
                ),
              ]),
            ),
          )
        ]),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Consumer(builder: (context, ref, child) {
              ref.watch(addMemberProvider);
              return _addMemberVM.isMemberSelectedChange
                  ? ButtonView(
                      text: "Xác nhận",
                      onTap: () async {
                        await _acceptClick(context);
                      },
                    )
                  : ButtonView(
                      text: "Xác nhận",
                      backgroundColor: ColorRes.colorDisable,
                      borderColor: ColorRes.colorDisable,
                      textColor: ColorRes.border,
                      onTap: () {},
                    );
            }),
          ),
          sloganBottomWidget(context)
        ],
      ),
    );
  }

  Widget _doorAllItemWidget() {
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
                ImageName.user,
                color: ColorRes.primaryBlack,
                width: 24,
                height: 24,
              ),
              Consumer(builder: (context, ref, child) {
                var provider = ref.watch(addMemberProvider);
                return Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Tất cả (${provider.members.length})",
                    style: TextStyles.text14Bold(context),
                  ),
                );
              }),
            ],
          ),
          Consumer(builder: (context, ref, child) {
            var provider = ref.watch(addMemberProvider);
            var members = provider.members;
            var isCheckedAll = members.any((element) => element.isSelected);
            var memberSelected = members.where((element) => element.isSelected).length;
            return Row(
              children: [
                Text(memberSelected != 0 ?"$memberSelected được chọn" : "", style: TextStyles.text12Bold(context),),
                const SizedBox(width: 8,),
                appCheckBox(
                  isChecked: isCheckedAll,
                  checkedImage: ImageName.checkbox2,
                  paddingHorizontal: Dimen.padding8,
                  onCheckedChange: (isCheck) {
                    provider.onAllMemberSelected(isCheck);
                  },
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _memberItemWidget(BuildContext context, Member item) {
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
          Expanded(
            child: Row(
              children: [
                SizedBox(
                  height: 32,
                  width: 32,
                  child: ClipOval(
                    child: ImageView(image:item.userPhoto),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      item.userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyles.text16(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Consumer(builder: (context, ref, child) {
            return appCheckBox(
              isChecked: item.isSelected,
              paddingHorizontal: Dimen.padding8,
              onCheckedChange: (isCheck) {
                _addMemberVM.onMemberSelected(item);
              },
            );
          }),
        ],
      ),
    );
  }

  Future<void> _acceptClick(BuildContext context) async {
    if (await Utils.isNetworkDisconnected()) {
      toastError(context,"Không có kết nối internet");
      return;
    }
    await _addMemberVM.setAccessMemberList(widget.door).whenComplete(() {
      toastSuccess(context,
          'Đã cập nhật danh sách thành viên ra vào ${widget.door.getDisplayName()} thành công');
      Navigator.of(context).pop();
    });
  }
}
