import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:sample/data/native.dart';
import 'package:sample/model/wifi.dart';

enum WIFI_STATE { processing, disabled, enabled }

class WifiVM with ChangeNotifier {
  WIFI_STATE wifiState = WIFI_STATE.processing;
  Wifi? currentWifi;
  Wifi? currentWifiSelected;
  List<Wifi> wifiList = [];

  init() async {
    // var isEnable = await Native.isWifiEnabled();
    // wifiState = isEnable ? WIFI_STATE.enabled : WIFI_STATE.disabled;
    // await onWifiConnectionChanged();
    // notifyListeners();
    if(Platform.isIOS) {
      return;
    }
    await listenWifiStateChange();
  }

  listenWifiStateChange() async {
    bool isEnabled = wifiState == WIFI_STATE.enabled;
    bool result = await Native.wifiListen(isEnabled);
    wifiState = result ? WIFI_STATE.enabled : WIFI_STATE.disabled;
    onWifiConnectionChanged();
    notifyListeners();
    listenWifiStateChange();
  }

  switchEnable() async {
    if (wifiState == WIFI_STATE.processing) {
      return;
    }
    wifiState = WIFI_STATE.processing;
    notifyListeners();
    var isEnabled = await Native.isWifiEnabled();
    await Native.wifiEnable(!isEnabled);
  }

  onWifiConnectionChanged() async {
    var isWifiEnabled = await Native.isWifiEnabled();
    currentWifi = isWifiEnabled ? await Native.currentWifi() : null;
    if (currentWifi != null) {
      currentWifi!.isConnected = true;
    }
  }

  var isScanning = false;

  scan() async {
    if (Platform.isIOS) {
      return;
    }
    wifiList = [];
    isScanning = true;
    if (wifiState == WIFI_STATE.enabled) {
      var newResults = await Native.wifiScan();
      // var results = newResults.where((e) => e.bssid != currentWifi?.bssid);
      wifiList.addAll(newResults);
    }
    notifyListeners();

    if (isScanning) {
      await Future.delayed(const Duration(milliseconds: 3000), () {
        if (isScanning) {
          scan();
        }
      });
    }
  }

  stopScan() async {
    isScanning = false;
  }

  Future<bool> connect() async {
    return await Native.connect(ssid: '', password: 'sycomore22');
  }

  startWifiAP() {
    Native.startWifiAP();
  }

  void onWifiChange(Wifi? wifi) {
    currentWifiSelected = wifi;
    notifyListeners();
  }
}
