import 'package:flutter/material.dart';
import 'package:provider/single_child_widget.dart';
import 'package:sample/model/history.dart';
import 'package:sample/ui/res/image_name.dart';

class TimeLineBuilder<T> extends SingleChildStatelessWidget {
  const TimeLineBuilder(
      {Key? key,
      required this.builder,
      this.header,
      this.child,
      this.isLeftAligned = true,
      this.itemGap = 12.0,
      this.gutterSpacing = 0.0,
      this.padding = const EdgeInsets.only(left: 24, right: 24),
      this.controller,
      this.lineColor = Colors.grey,
      this.physics,
      this.shrinkWrap = true,
      this.primary = false,
      this.reverse = false,
      this.indicatorSize = 20.0,
      this.lineGap = 0.0,
      this.indicatorColor = Colors.blue,
      this.indicatorStyle = PaintingStyle.fill,
      this.strokeCap = StrokeCap.butt,
      this.strokeWidth = 1.0,
      this.style = PaintingStyle.stroke,
      required this.data,
      this.indicator})
      : itemCount = data.length + (header != null ? 1 : 0),
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(data.length != 0),
        super(key: key, child: child);

  final List<T> data;
  final Widget? header;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;
  final Widget? indicator;
  final double itemGap;
  final double gutterSpacing;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController? controller;
  final int itemCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ListView.builder(
        itemCount: itemCount,
        controller: controller,
        physics: physics,
        shrinkWrap: true,
        padding: padding,
        itemBuilder: (context, index) {
          final isFirst = header == null ? index == 0 : index == 1;
          final isLast =
              index == (header == null ? data.length - 1 : data.length);
          final timelineTile = header == null || index != 0
              ? <Widget>[
                  CustomPaint(
                    foregroundPainter: _TimelinePainter(
                      hideDefaultIndicator: true,
                      lineColor: lineColor,
                      indicatorColor: indicatorColor,
                      indicatorSize: indicatorSize,
                      indicatorStyle: indicatorStyle,
                      isFirst: isFirst,
                      isLast: isLast,
                      lineGap: lineGap,
                      strokeCap: strokeCap,
                      strokeWidth: strokeWidth,
                      style: style,
                      itemGap: itemGap,
                    ),
                    child: SizedBox(
                      height: double.infinity,
                      width: indicatorSize,
                      child: indicator,
                    ),
                  ),
                  SizedBox(width: gutterSpacing),
                  Expanded(
                      child: builder(context,
                          data[header != null ? index - 1 : index], child)),
                ]
              : [const SizedBox()];
          return index == 0 && header != null
              ? header!
              : IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: isLeftAligned
                        ? timelineTile
                        : timelineTile.reversed.toList(),
                  ),
                );
        });
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.hideDefaultIndicator,
    required this.indicatorColor,
    required this.indicatorStyle,
    required this.indicatorSize,
    required this.lineGap,
    required this.strokeCap,
    required this.strokeWidth,
    required this.style,
    required this.lineColor,
    required this.isFirst,
    required this.isLast,
    required this.itemGap,
  })  : linePaint = Paint()
          ..color = lineColor
          ..strokeCap = strokeCap
          ..strokeWidth = strokeWidth
          ..style = style,
        circlePaint = Paint()
          ..color = indicatorColor
          ..style = indicatorStyle;

  final bool hideDefaultIndicator;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final double indicatorSize;
  final double lineGap;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;
  final Color lineColor;
  final Paint linePaint;
  final Paint circlePaint;
  final bool isFirst;
  final bool isLast;
  final double itemGap;

  @override
  void paint(Canvas canvas, Size size) {
    final indicatorRadius = indicatorSize / 2;
    final halfItemGap = itemGap / 2;
    final indicatorMargin = indicatorRadius + lineGap;

    final top = size.topLeft(Offset(indicatorRadius, 0.0 - halfItemGap));
    final centerTop = size.centerLeft(
      Offset(indicatorRadius, -indicatorMargin),
    );

    final bottom = size.bottomLeft(Offset(indicatorRadius, 0.0 + halfItemGap));
    final centerBottom = size.centerLeft(
      Offset(indicatorRadius, indicatorMargin),
    );

    if (!isFirst) canvas.drawLine(top, centerTop, linePaint);
    if (!isLast) canvas.drawLine(centerBottom, bottom, linePaint);

    if (!hideDefaultIndicator) {
      final Offset offsetCenter = size.centerLeft(Offset(indicatorRadius, 0));

      canvas.drawCircle(offsetCenter, indicatorRadius, circlePaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class HistoryBuilder extends SingleChildStatelessWidget {
  const HistoryBuilder(
      {Key? key,
      required this.builder,
      this.header,
      this.child,
      this.isLeftAligned = true,
      this.itemGap = 12.0,
      this.gutterSpacing = 0.0,
      this.padding = const EdgeInsets.only(left: 24, right: 24),
      this.controller,
      this.lineColor = Colors.grey,
      this.physics,
      this.shrinkWrap = true,
      this.primary = false,
      this.reverse = false,
      this.indicatorSize = 20.0,
      this.lineGap = 0.0,
      this.indicatorColor = Colors.blue,
      this.indicatorStyle = PaintingStyle.fill,
      this.strokeCap = StrokeCap.butt,
      this.strokeWidth = 1.0,
      this.style = PaintingStyle.stroke,
      required this.data})
      : itemCount = data.length + (header != null ? 1 : 0),
        assert(itemGap >= 0),
        assert(lineGap >= 0),
        assert(data.length != 0),
        super(key: key, child: child);

  final List<History> data;
  final Widget? header;
  final Widget Function(BuildContext context, History value, Widget? child)
      builder;
  final Widget? child;
  final double itemGap;
  final double gutterSpacing;
  final bool isLeftAligned;
  final EdgeInsets padding;
  final ScrollController? controller;
  final int itemCount;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final bool primary;
  final bool reverse;

  final Color lineColor;
  final double lineGap;
  final double indicatorSize;
  final Color indicatorColor;
  final PaintingStyle indicatorStyle;
  final StrokeCap strokeCap;
  final double strokeWidth;
  final PaintingStyle style;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return ListView.builder(
        itemCount: itemCount,
        controller: controller,
        physics: physics,
        shrinkWrap: true,
        padding: padding,
        itemBuilder: (context, index) {
          final isFirst = header == null ? index == 0 : index == 1;
          final isLast =
              index == (header == null ? data.length - 1 : data.length);
          final position = header == null ? index : index - 1;
          final timelineTile = header == null || index != 0
              ? <Widget>[
                  CustomPaint(
                    foregroundPainter: _TimelinePainter(
                      hideDefaultIndicator: true,
                      lineColor: lineColor,
                      indicatorColor: indicatorColor,
                      indicatorSize: indicatorSize,
                      indicatorStyle: indicatorStyle,
                      isFirst: isFirst,
                      isLast: isLast,
                      lineGap: lineGap,
                      strokeCap: strokeCap,
                      strokeWidth: strokeWidth,
                      style: style,
                      itemGap: itemGap,
                    ),
                    child: SizedBox(
                      height: double.infinity,
                      width: indicatorSize,
                      child: Image.asset(data[position].userObj == null
                          ? ImageName.warning
                          : data[position].isSuccess()
                              ? ImageName.done
                              : ImageName.error),
                    ),
                  ),
                  SizedBox(width: gutterSpacing),
                  Flexible(child: builder(context, data[position], child)),
                ]
              : [const SizedBox()];
          return index == 0 && header != null
              ? header!
              : IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: isLeftAligned
                        ? timelineTile
                        : timelineTile.reversed.toList(),
                  ),
                );
        });
  }
}
