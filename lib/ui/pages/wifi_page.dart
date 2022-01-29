import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/vm/wifi_vm.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/text.dart';

import 'base_page.dart';

final wifiProvider = ChangeNotifierProvider<WifiVM>(
  (ref) => WifiVM(),
);

/// https://stackoverflow.com/questions/36303123/how-to-programmatically-connect-to-a-wifi-network-given-the-ssid-and-password
/// https://www.youtube.com/watch?v=ssAKYGlmR4s
//ignore: must_be_immutable
class WifiPage extends BasePage {
  WifiPage({Key? key}) : super(key: key);

  late WifiVM wifiVM;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    wifiVM = ref.watch(wifiProvider);
    wifiVM.init();

    return defaultScaffold(
      child: Column(
        children: [
          wifiStateWidgets(),
          connectionWidget(),
          buttonPrimary(
              text: 'Scan',
              onPressed: () {
                requestWifiPermission(context);
              }),
          buttonPrimary(
              text: 'Connect',
              onPressed: () {
                wifiVM.connect();
              }),
          wifiListWidget()
        ],
      ),
    );
  }

  void requestWifiPermission(BuildContext context) async {
    requestPermission(Permission.location, onGranted: () {
      wifiVM.scan();
    }, onDenied: () {
      alertMessage(context, message: "Location permission require to scan");
    });
  }

  Widget wifiStateWidgets() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          child: Container(
            width: 96,
            height: 96,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.all(Radius.circular(Dimen.rowRadius)),
                border: Border.all(
                  color: ColorRes.disable,
                  width: 1,
                )),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: wifiStateImage(),
            ),
          ),
          onTap: () {
            wifiVM.switchEnable();
          },
        )
      ],
    );
  }

  Widget wifiStateImage() {
    if (wifiVM.isProcessing) {
      return Image.asset(
        'assets/images/wifi_anim.gif',
        fit: BoxFit.contain,
      );
    }
    if (wifiVM.isEnable) {
      return LayoutBuilder(builder: (context, constraint) {
        return Icon(
          Icons.wifi,
          color: ColorRes.primary,
          size: constraint.biggest.height,
        );
      });
    }
    return LayoutBuilder(builder: (context, constraint) {
      return Icon(
        Icons.wifi,
        color: ColorRes.disable,
        size: constraint.biggest.height,
      );
    });
  }

  Widget connectionWidget() {
    String infoText;
    if (wifiVM.connected) {
      infoText = 'SSID: ${wifiVM.ssid}\n'
          'BSSID: ${wifiVM.bssid}\n'
          'IP: ${wifiVM.ip}\n';
    } else {
      infoText = 'No connection information';
    }
    return Padding(
      padding: const EdgeInsets.only(top: Dimen.padding8),
      child: Text(infoText),
    );
  }

  Widget wifiListWidget() {
    dynamic list = wifiVM.wifiList;
    if (list == null || list.length == 0) {
      return Container(
        child: const Text('Permission required to scan wifi'),
      );
    }
    return ListView.builder(
        itemCount: list.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
              height: 50,
              color: Colors.blue[(index + 1) * 100],
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(list[index].ssid ?? 'unknown ssid'),
              ),
            ),
            onTap: () {},
          );
        });
  }
}
