import 'package:flutter/material.dart';
import 'package:sample/utils/base_state.dart';
import 'package:sample/pages/wifi.dart';
import 'package:sample/utils/native.dart';
import 'package:sample/widgets/ui.dart';

class MenuItem {
  final int id;
  final String text;

  MenuItem(this.id, this.text);
}

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends BaseState<MenuPage> {

  List<MenuItem> menuItems = [MenuItem(1, 'Toast'), MenuItem(2, 'Wifi')];

  @override
  Widget build(BuildContext context) {
    return defaultPageLayout(
      child: ListView.builder(
          itemCount: menuItems.length,
          itemBuilder: (BuildContext context, int index) {
            return listItem(index);
          }),
    );
  }

  Widget listItem(int index) {
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
      onTap: onMenuItemTap(item),
    );
  }

  GestureTapCallback onMenuItemTap(MenuItem item) {
    return () {
      switch (item.id) {
        case 1:
          Native.showToast("Hello !");
          break;
        case 2:
          push(WifiPage());
          break;
        default:
          break;
      }
    };
  }
}
