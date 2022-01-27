import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:sample/utils/native.dart';
import 'package:wifi_iot/wifi_iot.dart';

class WifiVM with ChangeNotifier {
  bool connected = false;
  bool isEnable = false;
  bool isProcessing = false;
  String ssid = '...';
  String bssid = '...';
  String ip = '...';
  int signalStrength = 0;
  List<WifiNetwork?>? wifiList;

  init() async {
    Native.wifiListen().then((value) {
      if (isProcessing) {
        return;
      }
      if (isEnable == value) {
        return;
      }
      isEnable = value;
      notifyListeners();
      loadWifiList();
      notifyListeners();
    });

    WiFiForIoTPlugin.isConnected().then((val) {
      connected = val;
      onConnectivityChanged();
      notifyListeners();
    });
  }

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
    if (connected) {
      ssid = await WiFiForIoTPlugin.getSSID() ?? '...';
      bssid = await WiFiForIoTPlugin.getBSSID() ?? '...';
      ip = await WiFiForIoTPlugin.getIP() ?? '...';
      signalStrength = await WiFiForIoTPlugin.getCurrentSignalStrength() ?? 0;
    }
  }

  loadWifiList() async {
    if (!isEnable) {
      return;
    }
    try {
      wifiList = await WiFiForIoTPlugin.loadWifiList();
      wifiList?.forEach((element) {});
      return;
    } catch (e) {
      dev.log(e.toString());
    }
    wifiList = null;
  }

  register() {
    try {
      WiFiForIoTPlugin.registerWifiNetwork(
        'Wee_Office1_2GHZ',
        password: 'weedigital@22',
        security: NetworkSecurity.WPA,
        isHidden: false,
      );
    } catch (e) {
      dev.log(e.toString());
    }
  }
}
