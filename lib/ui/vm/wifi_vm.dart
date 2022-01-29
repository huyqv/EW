import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:sample/model/wifi.dart';
import 'package:sample/utils/native.dart';

class WifiVM with ChangeNotifier {
  bool connected = false;
  bool isEnable = false;
  bool isProcessing = false;
  String ssid = '...';
  String bssid = '...';
  String ip = '...';
  List<Wifi>? wifiList;

  init() async {}

  switchEnable() async {
    if (isProcessing) {
      return;
    }
    isProcessing = true;
    notifyListeners();
    await Native.wifiEnable(!isEnable);
    isEnable = await Native.isWifiEnabled();
    await Future.delayed(const Duration(milliseconds: 1000));
    isProcessing = false;
    notifyListeners();
  }

  onConnectivityChanged() async {
    if (connected) {}
  }

  scan() async {
    if (!isEnable) {
      return;
    }
    try {
      wifiList = await Native.wifiScan();
      wifiList?.forEach((element) {});
      return;
    } catch (e) {
      dev.log(e.toString());
    }
  }

  connect() {
    Native.connect();
  }

}
