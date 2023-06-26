import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/image_name.dart';
import 'package:sample/ui/res/text_styles.dart';
import 'package:sample/ui/widgets/layout.dart';

enum RESULT_THEME { success, failure }


class ResultPage extends StatefulWidget {
  ResultPage({
    Key? key,
    required this.theme,
    required this.title,
    required this.message,
    this.buttons,
  }) : super(key: key);

  final RESULT_THEME theme;
  final String title;
  final String message;
  final List<Widget>? buttons;

  @override
  _ResultState createState() => _ResultState();
}

class _ResultState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Image.asset(
            ImageName.logoEuro,
            color: ColorRes.primary,
            width: 114,
            height: 28,
          ),
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  const SizedBox(
                    height: 78,
                  ),
                  Image.asset(
                    widget.theme == RESULT_THEME.success
                        ? ImageName.registerSuccess
                        : ImageName.registerError,
                    width: 134,
                    height: 134,
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(widget.title, style: TextStyles.text24Bold(context)),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    widget.message,
                    style: TextStyles.text14(context)
                        ?.copyWith(color: ColorRes.middleGray),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(children: [...widget.buttons ?? [], sloganBottomWidget(context)],),
            ],
          ),
        ),
      ),
    );
  }
}
