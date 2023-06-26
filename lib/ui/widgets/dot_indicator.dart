import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sample/ui/res/color.dart';

class DotIndicator extends AnimatedWidget {
  final PageController controller;
  final int itemCount;
  final int page;
  final ValueChanged<int> onPageSelected;
  final Color color;
  final double dotSize;
  final double maxZoom;
  final bool fixedSize;
  static const double _dotSpacing = 40.0;

  const DotIndicator(
      {Key? key,
      required this.controller,
      required this.itemCount,
      required this.onPageSelected,
      required this.color,
      required this.page,
      this.dotSize = 6.0,
      this.maxZoom = 40,
      this.fixedSize = false})
      : super(key: key, listenable: controller);

  Widget _buildDot(int index) {
    double selectNode = Curves.easeOut.transform(
      max(
        0.7,
        1.0 - ((controller.page ?? controller.initialPage) - index).abs(),
      ),
    );
    double zoom = 1.0 + (maxZoom - 8) * selectNode;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: SizedBox(
        width: fixedSize ? dotSize : zoom,
        child: Center(
          child: Material(
            color: page == index ? color : ColorRes.primary,
            type: MaterialType.card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: SizedBox(
                width: dotSize * (fixedSize ? 1 : 0.8),
                height: dotSize,
                child: InkWell(
                  onTap: () => onPageSelected(index),
                )),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(itemCount, _buildDot),
    );
  }
}
