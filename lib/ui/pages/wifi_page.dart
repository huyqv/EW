import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/model/wifi.dart';
import 'package:sample/ui/res/color.dart';
import 'package:sample/ui/res/dimen.dart';
import 'package:sample/ui/vm/wifi_vm.dart';
import 'package:sample/ui/widgets/layout.dart';
import 'package:sample/ui/widgets/text.dart';

import '../../utils/permission.dart';
import 'base_page.dart';

final wifiProvider = ChangeNotifierProvider<WifiVM>(
  (ref) {
    var vm = WifiVM();
    vm.init();
    return vm;
  },
);

class WifiPage extends BaseStatefulWidget {
  const WifiPage({Key? key}) : super(key: key);

  @override
  _WifiPageState createState() => _WifiPageState();
}

class _WifiPageState extends BaseState<WifiPage> {
  late WifiVM wifiVM;

  @override
  Widget build(BuildContext context) {
    wifiVM = ref.watch(wifiProvider);
    return defaultScaffold(
      child: Column(
        children: [
          wifiStateWidgets(ref),
          Consumer(builder: (context, ref, _) {
            return connectionWidget(wifiVM.currentWifi);
          }),
          wifiButtons(context),
          Consumer(builder: (context, ref, _) {
            return wifiListWidget(wifiVM.wifiList);
          }),
        ],
      ),
    );
  }

  Widget wifiButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buttonPrimary(
            text: 'Scan',
            onPressed: () {
              requestWifiPermission(context);
            }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: buttonPrimary(
              text: 'Connect',
              onPressed: () {
                wifiVM.connect();
              }),
        ),
        buttonPrimary(
            text: 'Hotspot',
            onPressed: () {
              wifiVM.startWifiAP();
            }),
      ],
    );
  }

  void requestWifiPermission(BuildContext context) async {
    requestPermission(Permission.location, onGranted: () {
      wifiVM.scan();
    }, onDenied: () {
      alertMessage(context, message: "Location permission require to scan");
    });
  }

  Widget wifiStateWidgets(WidgetRef ref) {
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
              child: Consumer(builder: (context, ref, _) {
                return wifiStateImage(wifiVM.wifiState);
              }),
            ),
          ),
          onTap: () {
            wifiVM.switchEnable();
          },
        )
      ],
    );
  }

  Widget wifiStateImage(WIFI_STATE wifiState) {
    switch (wifiState) {
      case WIFI_STATE.disabled:
        return LayoutBuilder(builder: (context, constraint) {
          return Icon(
            Icons.wifi,
            color: ColorRes.disable,
            size: constraint.biggest.height,
          );
        });
      case WIFI_STATE.enabled:
        return LayoutBuilder(builder: (context, constraint) {
          return Icon(
            Icons.wifi,
            color: ColorRes.primary,
            size: constraint.biggest.height,
          );
        });
      default:
        return Image.asset(
          'assets/images/wifi_anim.gif',
          fit: BoxFit.contain,
        );
    }
  }

  Widget connectionWidget(Wifi? wifi) {
    String infoText;
    if (wifi != null) {
      infoText = 'SSID: ${wifi.ssid}\n'
          'BSSID: ${wifi.bssid}';
    } else {
      infoText = 'No connection information';
    }
    return Text(infoText);
  }

  Widget wifiListWidget(List<Wifi> list) {
    return Expanded(
      child: ListView.builder(
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            var item = list[index];
            var itemText = item.ssid ?? 'unknown ssid';
            if (item.isConnected) {
              itemText += '\nconnected';
            }
            return GestureDetector(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: Dimen.padding8, horizontal: Dimen.padding8),
                height: 50,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(itemText),
                ),
              ),
              onTap: () {},
            );
          }),
    );
  }
}
