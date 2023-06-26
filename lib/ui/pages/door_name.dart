import 'package:flutter/material.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/door_vm.dart';
import 'package:sample/ui/vm/home_vm.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';

import '../res/dimen.dart';

class DoorNameDialog extends BaseStatefulWidget {

  const DoorNameDialog({Key? key}) : super(key: key);

  @override
  _DoorNameDialogState createState() => _DoorNameDialogState();
}

class _DoorNameDialogState extends BaseState<DoorNameDialog> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _doorFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();
  late DoorVM _doorVM;
  late HomeVM _homeVM;
  @override
  void initState() {
    _doorVM = ref.read<DoorVM>(doorProvider);
    _homeVM = ref.read<HomeVM>(homeProvider);
    _textController.text = _homeVM.selectedDoor!.getDisplayName();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16),
      child: SizedBox(
        height: height(context) * 0.8,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  padding(top: Dimen.padding24),
                  Container(
                    width: 45,
                    height: 4,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        border:
                            Border.all(color: Colors.transparent, width: 0.1),
                        color: ColorRes.gray),
                  ),
                  padding(top: Dimen.padding24),
                  Text(
                    "Đổi tên cửa",
                    style: TextStyles.text24Bold(context),
                  ),
                  padding(top: Dimen.padding48),
                  InputTextOutline(
                    controller: _textController,
                    hintText: "Nhập tên cửa",
                    prefixIcon: ImageName.door,
                    unFocusBorderColor: ColorRes.middleGray,
                    focusBorderColor: ColorRes.primary,
                    focusNode: _doorFocusNode,
                    onChange: (text) {},
                    validator: (String? text) {
                      if (text != null && text.isNotEmpty) {
                        return null;
                      } else {
                        return "Vui lòng không để trống";
                      }
                    },
                  ),
                  padding(top: Dimen.padding24),
                  Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Tên cửa được đề xuất",
                        style: TextStyles.text12Gray(context),
                        textAlign: TextAlign.start,
                      )),
                  padding(top: Dimen.padding8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: List.generate(
                            _doorVM.doorSuggestName.length,
                            (index) => GestureDetector(
                                  onTap: () {
                                    _textController.text =
                                        _doorVM.doorSuggestName[index];
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: ColorRes.lightGray,
                                      border:
                                          Border.all(color: ColorRes.border),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _doorVM.doorSuggestName[index],
                                      style: TextStyles.text12Gray(context)
                                          ?.copyWith(
                                              color: ColorRes.primaryBlack),
                                    ),
                                  ),
                                ))),
                  )
                ],
              ),
            ),
            ButtonView(
                padding: const EdgeInsets.only(bottom: 24),
                text: "Xác nhận",
                onTap: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _doorVM.updateDoorName(
                        _homeVM.selectedDoor!, _textController.text,
                        onSuccess: () {
                      toastSuccess(context, "Đổi tên cửa thành công!");
                      Navigator.of(context).pop();
                    }, onError: () {
                      toastSuccess(context, "Đổi tên cửa thất bại!");
                    });
                  }
                }),
          ],
        ),
      ),
    );
  }
}
