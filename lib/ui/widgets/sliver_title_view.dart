import 'package:flutter/material.dart';

class SliverTitleView extends StatefulWidget {
  final Widget child;
  const SliverTitleView({
    Key? key,
    required this.child,
  }) : super(key: key);
  @override
  _SliverTitleViewState createState() {
    return new _SliverTitleViewState();
  }
}
class _SliverTitleViewState extends State<SliverTitleView> {
  ScrollPosition? _position;
  bool _visible = false;
  @override
  void dispose() {
    _removeListener();
    super.dispose();
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeListener();
    _addListener();
  }
  void _addListener() {
    _position = Scrollable.of(context)?.position;
    _position?.addListener(_positionListener);
    _positionListener();
  }
  void _removeListener() {
    _position?.removeListener(_positionListener);
  }
  void _positionListener() {
    final FlexibleSpaceBarSettings? settings =
    context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    bool visible = settings == null || settings.currentExtent <= settings.minExtent;
    if (_visible != visible) {
      setState(() {
        _visible = visible;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !_visible,
      child: widget.child,
    );
  }
}