import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/text_styles.dart';

class InputTextOutline extends StatefulWidget {
  final TextEditingController controller;
  final TextInputType? textInputType;
  final void Function(String)? onSubmit;
  final void Function(String) onChange;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final TextStyle? textStyle;
  final TextStyle? hintStyle;
  final String? hintText;
  final int? maxLines;
  final String? prefixIcon;
  final String? suffixIcon;
  final double height;
  final bool obscureText;
  final bool readOnly;
  final bool enable;
  final bool autoFocus;
  final String? initialValue;
  final void Function()? onTap;
  final Color focusBorderColor;
  final Color unFocusBorderColor;
  final int? maxLength;
  final EdgeInsetsGeometry padding;
  final Color fillColor;
  final FocusNode focusNode;
  final VoidCallback? onSuffixIconClick;
  final VoidCallback? onPrefixIconClick;
  final List<TextInputFormatter>? inputFormatters;

  const InputTextOutline(
      {Key? key,
      required this.controller,
      this.textInputType,
      this.onSubmit,
      required this.onChange,
      this.validator,
      this.textStyle,
      this.hintText,
      this.hintStyle,
      this.maxLines,
      this.prefixIcon,
      this.suffixIcon,
      this.height = 56,
      this.obscureText = false,
      this.readOnly = false,
      this.textInputAction,
      this.enable = true,
      this.autoFocus = false,
      this.initialValue,
      this.onTap,
      this.focusBorderColor = Colors.white,
      this.unFocusBorderColor = Colors.white,
      this.maxLength,
      this.padding = EdgeInsets.zero,
      this.fillColor = Colors.transparent,
      required this.focusNode,
      this.onSuffixIconClick,
      this.onPrefixIconClick,
      this.inputFormatters})
      : super(key: key);

  @override
  _InputTextOutlineState createState() => _InputTextOutlineState();
}

class _InputTextOutlineState extends State<InputTextOutline> {
  var _hasError = false;

  @override
  void initState() {
    widget.focusNode.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Theme(
        data: ThemeData(
          colorScheme: ThemeData().colorScheme.copyWith(
                secondary: ColorRes.primary,
              ),
        ),
        child: TextFormField(
          controller: widget.controller,
          keyboardType: widget.textInputType ?? TextInputType.text,
          onFieldSubmitted: widget.onSubmit,
          onChanged: (text) {
            setState(() {
              widget.onChange(text);
            });
          },
          validator: (value) {
            if (widget.validator != null) {
              if (widget.validator!(value) != null) {
                setState(() {
                  _hasError = true;
                });
              } else {
                setState(() {
                  _hasError = false;
                });
              }
            }
            return widget.validator!(value);
          },
          obscureText: widget.obscureText,
          readOnly: widget.readOnly,
          style: widget.textStyle ?? TextStyles.text16(context),
          enabled: widget.enable,
          textAlign: TextAlign.start,
          textInputAction: widget.textInputAction,
          autofocus: widget.autoFocus,
          initialValue: widget.initialValue,
          cursorColor: widget.focusBorderColor,
          onTap: widget.onTap,
          maxLength: widget.maxLength,
          focusNode: widget.focusNode,
          inputFormatters: widget.inputFormatters,
          decoration: InputDecoration(
            filled: true,
            fillColor: widget.fillColor,
            focusColor: ColorRes.primary,
            counterText: "",
            border: widget.controller.text.isNotEmpty
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: widget.focusBorderColor,
                    ),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: widget.unFocusBorderColor,
                    ),
                  ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: _hasError
                    ? Colors.red
                    : widget.focusBorderColor,
              ),
            ),
            enabledBorder: widget.controller.text.isNotEmpty
                ? OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: widget.unFocusBorderColor,
                    ),
                  )
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(
                      color: widget.unFocusBorderColor,
                    ),
                  ),
            prefixIcon: widget.prefixIcon != null
                ? GestureDetector(
                    onTap: widget.onPrefixIconClick,
                    child: SizedBox(
                      child: Center(
                          child: SizedBox(
                              child: Image.asset(
                        widget.prefixIcon!,
                        width: 24,
                        height: 24,
                        color: _hasError
                            ? Colors.red
                            : widget.focusNode.hasFocus ||
                                    widget.controller.text.isNotEmpty
                                ? widget.focusBorderColor
                                : widget.unFocusBorderColor,
                      ))),
                      width: 24,
                      height: 24,
                    ),
                  )
                : null,
            suffixIcon: widget.suffixIcon != null
                ? GestureDetector(
                    onTap: widget.onSuffixIconClick,
                    child: SizedBox(
                      child: Center(
                          child: SizedBox(
                              child: Image.asset(
                        widget.suffixIcon!,
                        width: 24,
                        height: 24,
                        color: _hasError
                            ? Colors.red
                            : widget.focusNode.hasFocus ||
                                    widget.controller.text.isNotEmpty
                                ? widget.focusBorderColor
                                : widget.unFocusBorderColor,
                      ))),
                      width: 24,
                      height: 24,
                    ),
                  )
                : null,
            hintText: widget.hintText,
            hintStyle: widget.hintStyle ??
                TextStyles.text16(context)?.copyWith(color: ColorRes.disable),
          ),
        ),
      ),
    );
  }
}
