import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/pages/base_page.dart';
import 'package:sample/pages/home_page.dart';
import 'package:sample/pages/wifi_page.dart';
import 'package:sample/utils/native.dart';
import 'package:sample/widgets/ui.dart';

class MenuItem {
  final int id;
  final String text;

  MenuItem(this.id, this.text);
}

class MenuPage extends BasePage {
  MenuPage({Key? key}) : super(key: key);

  late List<MenuItem> menuItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    menuItems = [
      MenuItem(1, 'Toast'),
      MenuItem(2, 'Home'),
      MenuItem(3, 'Wifi')
    ];
    return defaultScaffold(
      child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (BuildContext context, int index) {
            return listItem(context, index);
          }),
    );
  }

  Widget listItem(BuildContext context, int index) {
    MenuItem item = menuItems[index];
    return GestureDetector(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        height: 50,
        color: Colors.blue[(index + 1) * 100],
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(item.text),
        ),
      ),
      onTap: onMenuItemTap(context, item),
    );
  }

  GestureTapCallback onMenuItemTap(BuildContext context, MenuItem item) {
    return () {
      switch (item.id) {
        case 1:
          Native.showToast("Hello !");
          break;
        case 2:
          push(context, HomePage());
          break;
        case 3:
          push(context, WifiPage());
          break;
        default:
          break;
      }
    };
  }
}
