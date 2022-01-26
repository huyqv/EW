import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/ui/vm/wifi_vm.dart';

import 'base_page.dart';

final wifiProvider = ChangeNotifierProvider<WifiVM>(
  (ref) => WifiVM(),
);

//ignore: must_be_immutable
class WifiPage extends BasePage {
  WifiPage({Key? key}) : super(key: key);

  late WifiVM wifiVM;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    wifiVM = ref.watch(wifiProvider);
    wifiVM.observeWifiStatus();
    return defaultScaffold(
      child: Column(
        children: [
          Row(children: wifiInfoWidgets()),
          CupertinoSwitch(
            value: false,
            onChanged: (value) {},
          ),
        ],
      ),
    );
  }

  List<Widget> wifiInfoWidgets() {
    String connectStatus = wifiVM.connected ? 'Connected' : 'Disconnected';
    return [
      Container(
        height: 50,
        padding: const EdgeInsets.only(left: 16),
        child: Align(
          alignment: Alignment.center,
          child: Text('...'),
        ),
      ),
      const Spacer(),
      Container(
        height: 50,
        padding: const EdgeInsets.only(right: 16),
        child: Align(
          alignment: Alignment.center,
          child: Text(connectStatus),
        ),
      ),
    ];
  }
}
