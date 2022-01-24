import 'package:flutter/material.dart';
import 'package:sample/base/base_state.dart';
import 'package:sample/const/color_res.dart';
import 'package:sample/pages/wifi.dart';

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

  List<MenuItem> menuItems = [
    MenuItem(1, 'Wifi')
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorRes.defaultBackgroundColor,
        body: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: menuItems.length,
            itemBuilder: (BuildContext context, int index) {
              return listItem(menuItems[index]);
            }));
  }

  Widget listItem(MenuItem item) {
    return GestureDetector(
      child: SizedBox(
        height: 50,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(item.text),
        ),
      ),
      onTap: () {
        switch (item.id) {
          case 1:
            push(const WifiPage());
            break;
          default:
            break;
        }
      },
    );
  }
}
