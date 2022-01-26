import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class WifiVM with ChangeNotifier {

  bool connected = false;
  String ssidName = '...';

  void init() async{
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt! < 29) {
        return;
      }
      return;
    }
    if (Platform.isIOS) {
      // iOS-specific code
    }
  }
  void observeWifiStatus() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi) {
        connected = true;
      } else {
        connected = true;
      }
    });
  }
}
