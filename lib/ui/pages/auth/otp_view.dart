import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/text_styles.dart';

class OtpView extends StatefulWidget {
  const OtpView({
    Key? key,
    required this.onChanged,
  }) : super(key: key);
  final void Function(String?) onChanged;

  @override
  _OtpViewState createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  late final TextEditingController _otpController;
  late final FocusNode _focusNode;

  String getCharacter(int index) {
    if (_otpController.text.length > index) {
      return _otpController.text[index];
    }
    return "";
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    _otpController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _focusNode.unfocus();
        return true;
      },
      child: Padding(
        padding: const EdgeInsets.all(54),
        child: SizedBox(
          height: 48,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      _focusNode.unfocus();
                      _focusNode.requestFocus();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        textBox(context, getCharacter(0)),
                        textBox(context, getCharacter(1)),
                        textBox(context, getCharacter(2)),
                        textBox(context, getCharacter(3)),
                      ],
                    ),
                  )),
              Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: TextFormField(
                    controller: _otpController,
                    maxLength: 4,
                    onChanged: (text) {
                      setState(() {
                        widget.onChanged(text);
                      });
                    },
                    focusNode: _focusNode,
                    autofocus: true,
                    cursorColor: Colors.white,
                    cursorHeight: 0,
                    cursorWidth: 0,
                    textInputAction: TextInputAction.done,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    ],
                    style: TextStyles.text24Bold(context)
                        ?.copyWith(color: Colors.transparent),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        counterText: ""),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget textBox(BuildContext context, String input) {
    return Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: ColorRes.white,
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            border: Border.all(width: 1, color: ColorRes.primary)),
        child: Text(
          input,
          style: TextStyles.text24Bold(context),
        ));
  }
}
