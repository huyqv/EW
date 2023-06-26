import 'dart:async';

import 'package:flutter/material.dart';

import '../ui/pages/result_page.dart';

class Routing {
  static final Routing _instance = Routing._internal();

  factory Routing() {
    return _instance;
  }

  Routing._internal();

  static Future<T?> navigate2<T>(BuildContext context, WidgetBuilder builder, {bool replace = false, required String routeName}) async {
    if (replace) {
      return await Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              settings: RouteSettings(name: routeName),
              builder: builder,
              ));
    }

    return Navigator.push<T>(context, MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: builder
    ));
  }

  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, WidgetBuilder builder, {required String routeName,required String oldRouteName}) async {
     return await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute<T>(
              settings: RouteSettings(name: routeName),
              builder: builder
          ), ModalRoute.withName(oldRouteName));
  }

  static Navigator createNewRouter(Widget Function(BuildContext context) builder, routeName) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
          builder: builder,
          settings: RouteSettings(name: routeName)),
    );
  }

  static void popToRoot(BuildContext context) {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  static Future openDialog(BuildContext context, WidgetBuilder builder,
      {bool? fullscreen}) async {
    return await Navigator.push(
        context,
        MaterialPageRoute(
          builder: builder,
          fullscreenDialog: fullscreen ?? false,
        ));
  }

  static Future showResult<T>(BuildContext context,
      {required String routeName, required ResultPage page}) async {
    return Routing.navigate2(
      context,
      (context) => page,
      routeName: routeName,
    );
  }
}
