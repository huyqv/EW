import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:sample/ui/pages/add_member/door_list.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/face/face_capture.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/add_member_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/utils/string_extension.dart';

class AddMemberPage extends BaseStatefulWidget {
  const AddMemberPage({Key? key}) : super(key: key);

  @override
  _AddMemberPageState createState() => _AddMemberPageState();
}

class _AddMemberPageState extends BaseState<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _doorFocusNode = FocusNode();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doorController = TextEditingController();
  late AddMemberVM _vm;

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _doorFocusNode.dispose();
    _nameController.dispose();
    _doorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _vm = ref.read(addMemberProvider);
    // _vm.listenDoorList();
    return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        appBar: widgetAppBar(
          context: context,
          centerWidget: logoDark(),
        ),
        body: Padding(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Thêm mới thành viên",
                              style: TextStyles.text24Bold(context),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 16, bottom: 40),
                              child: Text(
                                "Vui lòng điền đầy đủ thông tin của thành viên được phép ra vào cửa",
                                textAlign: TextAlign.center,
                                style: TextStyles.text14Bold(context)
                                    ?.copyWith(color: ColorRes.middleGray),
                              ),
                            ),
                            InputTextOutline(
                              controller: _nameController,
                              prefixIcon: ImageName.user,
                              focusBorderColor: ColorRes.primary,
                              unFocusBorderColor: ColorRes.middleGray,
                              hintText: "Họ và tên",
                              hintStyle: TextStyles.text16Gray(context),
                              textStyle: TextStyles.text16Bold(context),
                              focusNode: _nameFocusNode,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(RegExp(
                                    "[0-9a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂẠẢẤẦẨẪẬẮẰẲẴẶẸẺẼỀỀỂưăạảấầẩẫậắằẳẵặẹẻẽềềểỄỆỈỊỌỎỐỒỔỖỘỚỜỞỠỢỤỦỨỪễệỉịọỏốồổỗộớờởỡợụủứừỬỮỰỲỴÝỶỸửữựỳỵỷỹ ]")),
                              ],
                              validator: (text) {
                                if (text!.trim().validateName()) {
                                  return null;
                                } else {
                                  return "Thông tin không được để trống";
                                }
                              },
                              onChange: (String) {},
                            ),
                          ])),
                  Column(
                    children: [
                      ButtonView(
                        text: "Tiếp theo",
                        onTap: () {
                          if ((_formKey.currentState?.validate() ?? false) &&
                              _nameController.text.trim().isNotEmpty) {
                            FocusScope.of(context).unfocus();
                            push(
                                context,
                                FaceCapture(
                                    userName: _nameController.text.trim()));
                          }
                        },
                      ),
                      sloganBottomWidget(context),
                    ],
                  )
                ])));
  }

  Widget _doorListTextField() {
    return Consumer(
      builder: (context, ref, child) {
        var doorSelected = ref
            .watch(addMemberProvider)
            .doors
            .where((element) => element.isSelected);
        _doorController.text =
            "Cửa được ra vào ${doorSelected.isNotEmpty ? "(${doorSelected.length} cửa)" : ""}";
        return InputTextOutline(
          padding: const EdgeInsets.only(top: 24),
          prefixIcon: ImageName.door,
          suffixIcon: ImageName.expandMore,
          focusBorderColor: ColorRes.primary,
          unFocusBorderColor: ColorRes.middleGray,
          hintText: "Cửa được ra vào",
          hintStyle: TextStyles.text16Gray(context),
          textStyle: TextStyles.text16Bold(context),
          focusNode: _doorFocusNode,
          readOnly: true,
          controller: _doorController,
          validator: (text) {
            if (text!.validateName()) {
              return null;
            } else {
              return "Thông tin không được để trống";
            }
          },
          onChange: (text) {
            // _vm.userName = text;
          },
          onTap: () {
            _nameFocusNode.unfocus();
            _showDialogSelectDoor(context);
          },
        );
      },
    );
  }

  void _showDialogSelectDoor(BuildContext context) {
    showMaterialModalBottomSheet(
        context: context,
        duration: const Duration(milliseconds: 500),
        enableDrag: false,
        isDismissible: false,
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(40), topLeft: Radius.circular(40))),
        builder: (context) => const DoorListView());
  }
}
