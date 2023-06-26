import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/pages/base_page.dart';
import 'package:sample/ui/pages/door_tutorial_page.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/vm/door_vm.dart';
import 'package:sample/ui/widgets/app_bar.dart';
import 'package:sample/ui/widgets/button.dart';
import 'package:sample/ui/widgets/input_text.dart';

var itemNameSelectedProvider = StateProvider((ref) => -1);

class DoorInfoPage extends BaseStatefulWidget {
  const DoorInfoPage({Key? key}) : super(key: key);

  @override
  _DoorInfoPageState createState() => _DoorInfoPageState();
}

class _DoorInfoPageState extends BaseState<DoorInfoPage> {
  late final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late DoorVM _doorVM;
  final FocusNode _doorFocusNode = FocusNode();

  String? _validateText(String? text) {
    if (text != null && text.isNotEmpty && text.trim().isNotEmpty) {
      return null;
    } else {
      _textController.text = "";
      return "Vui lòng không để trống";
    }
  }

  @override
  Widget build(BuildContext context) {
    _doorVM = ref.read(doorProvider);
    var itemSelectedState = ref.read(itemNameSelectedProvider.state);
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: widgetAppBar(
        context: context,
        centerWidget: logoDark(),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      "Thông tin cửa",
                      style: TextStyles.text24Bold(context),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Text(
                      "Vui lòng điền đầy đủ thông tin cửa ra vào",
                      style: TextStyles.text14(context)
                          ?.copyWith(color: ColorRes.middleGray),
                    ),
                    const SizedBox(
                      height: 36,
                    ),
                    InputTextOutline(
                      controller: _textController,
                      hintText: "Nhập tên cửa",
                      prefixIcon: ImageName.door,
                      unFocusBorderColor: ColorRes.middleGray,
                      focusBorderColor: ColorRes.primary,
                      validator: _validateText,
                      focusNode: _doorFocusNode,
                      onChange: (text) {
                        if(text.isNotEmpty) {
                          _formKey.currentState?.validate();
                        }
                        itemSelectedState.state = -1;
                      },
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tên cửa được đề xuất",
                          style: TextStyles.text12Gray(context),
                          textAlign: TextAlign.start,
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: List.generate(
                              _doorVM.doorSuggestName.length,
                              (index) => GestureDetector(
                                    onTap: () {
                                      itemSelectedState.state = index;
                                      _textController.text =
                                          _doorVM.doorSuggestName[index];
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: ref.watch(
                                                  itemNameSelectedProvider) ==
                                              index
                                          ? BoxDecoration(
                                              color: ColorRes.primaryLight,
                                              border: Border.all(
                                                  color: ColorRes.primary),
                                              borderRadius:
                                                  BorderRadius.circular(4))
                                          : BoxDecoration(
                                              color: ColorRes.lightGray,
                                              border: Border.all(
                                                  color: ColorRes.border),
                                              borderRadius:
                                                  BorderRadius.circular(4)),
                                      child: Text(
                                        _doorVM.doorSuggestName[index],
                                        style: TextStyles.text12Gray(context)
                                            ?.copyWith(
                                                color: ref.watch(
                                                            itemNameSelectedProvider) ==
                                                        index
                                                    ? ColorRes.primary
                                                    : ColorRes.primaryBlack),
                                      ),
                                    ),
                                  ))),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ButtonView(
        padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
        text: "Tiếp theo",
        onTap: () {
          if (_formKey.currentState?.validate() ?? false) {
            _doorFocusNode.unfocus();
            _doorVM.doorName = _textController.text;
            push(context, const DoorTutorialPage());
          }
        },
      ),
    );
  }
}
