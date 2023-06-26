import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/layout.dart';

class Pin extends StatefulWidget {
  const Pin(
      {Key? key,
      required this.onChanged,
      required this.focusNode,
      required this.textEditingController,
      this.isScale = false, this.onTap})
      : super(key: key);
  final void Function(String? pin) onChanged;
  final FocusNode focusNode;
  final TextEditingController textEditingController;
  final bool isScale;
  final VoidCallback? onTap;

  @override
  _PinViewState createState() => _PinViewState();
}

class _PinViewState extends State<Pin> {
  Color _color1 = Colors.black12;
  Color _color2 = Colors.black12;
  Color _color3 = Colors.black12;
  Color _color4 = Colors.black12;
  Color _color5 = Colors.black12;
  double _width1 = 12;
  double _width2 = 12;
  double _width3 = 12;
  double _width4 = 12;
  double _width5 = 12;
  bool _isEnd = false;
  double _height = 12;

  void onTextChange(String text) {
    if (text.isEmpty) {
      _color1 = Colors.black12;
      _height = 12;
    } else if (text.length == 1) {
      _width1 = 12;
      _color1 = Colors.blue;
    } else if (text.length == 2) {
      _width1 = 60;
      _width2 = 12;
      _color1 = Colors.blue;
      _color2 = Colors.black12;
    } else if (text.length == 3) {
      _width1 = 60;
      _width2 = 60;
      _width3 = 12;
      _color1 = Colors.blue.withOpacity(0.2);
      _color2 = Colors.blue;
      _color3 = Colors.black12;
    } else if (text.length == 4) {
      _width1 = 60;
      _width2 = 60;
      _width3 = 60;
      _width4 = 12;
      _color1 = Colors.blue.withOpacity(0.2);
      _color2 = Colors.blue.withOpacity(0.4);
      _color3 = Colors.blue;
      _color4 = Colors.black12;
    } else if (text.length == 5) {
      _width1 = 60;
      _width2 = 60;
      _width3 = 60;
      _width4 = 60;
      _width5 = 12;
      _isEnd = false;
      _color1 = Colors.blue.withOpacity(0.2);
      _color2 = Colors.blue.withOpacity(0.4);
      _color3 = Colors.blue.withOpacity(0.6);
      _color4 = Colors.blue;
      _color5 = Colors.black12;
    } else if (text.length == 6) {
      if (widget.isScale) {
        _width1 = 25;
        _width2 = 25;
        _width3 = 25;
        _width4 = 25;
        _width5 = 25;
        _height = 6;
      } else {
        _width1 = 60;
        _width2 = 60;
        _width3 = 60;
        _width4 = 60;
        _width5 = 60;
        _height = 12;
      }
      _isEnd = true;
      _color1 = Colors.blue.withOpacity(0.2);
      _color2 = Colors.blue.withOpacity(0.4);
      _color3 = Colors.blue.withOpacity(0.6);
      _color4 = Colors.blue.withOpacity(0.8);
      _color5 = Colors.blue;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.textEditingController.removeListener(() {
      onTextChange(widget.textEditingController.text);
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _color1 = Colors.black12;
    _color2 = Colors.black12;
    _color3 = Colors.black12;
    _color4 = Colors.black12;
    _color5 = Colors.black12;
    _width1 = 12;
    _width2 = 12;
    _width3 = 12;
    _width4 = 12;
    _width5 = 12;
    _isEnd = false;
    var text = widget.textEditingController.text;
    onTextChange(text);

    return Material(
      child: ColoredBox(
        color: Colors.white,
        child: Center(
          child: SizedBox(
                height: 100,
                width: widget.isScale ? 105 : 254,
                child: Stack(
                  children: [
                    Positioned(
                      width: width(context),
                      height: 100,
                      child: SizedBox(
                        child: Stack(
                          children: [
                            Positioned(
                              left: widget.isScale ? 100 : 240,
                              right: widget.isScale
                                  ? width(context) - 125
                                  : width(context) - 300,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _height,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _isEnd ? Colors.transparent : Colors.black12,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            ),
                            Positioned(
                              left: widget.isScale ? 80 : 192,
                              right: widget.isScale
                                  ? width(context) - 105
                                  : width(context) - 252,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _width5,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _color5,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            ),
                            Positioned(
                              left: widget.isScale ? 60 : 144,
                              right: widget.isScale
                                  ? width(context) - 85
                                  : width(context) - 204,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _width4,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _color4,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            ),
                            Positioned(
                              left: widget.isScale ? 40 : 96,
                              right: widget.isScale
                                  ? width(context) - 65
                                  : width(context) - 156,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _width3,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _color3,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            ),
                            Positioned(
                              left: widget.isScale ? 20 : 48,
                              right: widget.isScale
                                  ? width(context) - 45
                                  : width(context) - 108,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _width2,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _color2,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: widget.isScale
                                  ? width(context) - 25
                                  : width(context) - 60,
                              top: 0,
                              bottom: 0,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: AnimatedContainer(
                                  width: _width1,
                                  height: _height,
                                  decoration: BoxDecoration(
                                    color: _color1,
                                    border: Border.all(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: TextFormField(
                          onTap: widget.onTap,
                          maxLength: 6,
                          controller: widget.textEditingController,
                          onChanged: (text) {
                            widget.onChanged(text);
                            setState(() {});
                          },
                          focusNode: widget.focusNode,
                          autofocus: true,
                          cursorWidth: 0,
                          cursorHeight: 0,
                          showCursor: false,
                          textInputAction: TextInputAction.done,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                          ],
                          style: TextStyles.text24Bold(context)
                              ?.copyWith(color: Colors.transparent, fontSize: 1),
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              border: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              counterText: ""),
                        ))
                  ],
                ),
              ),
            ),
        ),
    );
  }
}
