import 'dart:developer' as dev;
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class ConnectivityVM with ChangeNotifier {
  bool connected = false;

  init() async {
    if (Platform.isIOS) {
      // iOS-specific code
      return;
    }
    if (Platform.isAndroid) {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt! < 29) {
        // Android sdk < 29 specific code
      } else {
        // Android sdk >= 29 specific code
      }
    }
  }

  observeWifiStatus() async {
    try {
      dynamic result = await Connectivity().checkConnectivity();
      onConnectivityChange(result);
    } on PlatformException catch (e) {
      dev.log('Could not check connectivity status');
      return;
    }
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      onConnectivityChange(result);
    });
  }

  onConnectivityChange(ConnectivityResult result) {
    if (result == ConnectivityResult.wifi) {
      connected = true;
    } else {
      connected = true;
    }
    notifyListeners();
  }
}
