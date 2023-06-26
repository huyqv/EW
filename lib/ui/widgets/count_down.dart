import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/text_styles.dart';

class Countdown extends AnimatedWidget {
  const Countdown({Key? key, required this.animation})
      : super(key: key, listenable: animation);
  final Animation<int> animation;

  @override
  build(BuildContext context) {
    Duration clockTimer = Duration(seconds: animation.value);

    String timerText =
        '${clockTimer.inMinutes.remainder(60).toString()}:${clockTimer.inSeconds.remainder(60).toString().padLeft(2, '0')}';

    if (kDebugMode) {
      print('animation.value  ${animation.value} ');
      print('inMinutes ${clockTimer.inMinutes.toString()}');
      print('inSeconds ${clockTimer.inSeconds.toString()}');
      print(
          'inSeconds.remainder ${clockTimer.inSeconds.remainder(60).toString()}');
    }
    return Text(
      timerText,
      style: TextStyles.text14Bold(context)?.copyWith(color: ColorRes.primary),
    );
  }
}
