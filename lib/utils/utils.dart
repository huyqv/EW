import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';

class Utils {
  static String assetPath(String name) {
    return 'assets/images/$name.png';
  }

  static String assetGifPath(String name) {
    return 'assets/images/$name.gif';
  }

  static Future<void> onNetworkConnected(
      VoidCallback onConnect,
      VoidCallback onDisconnect,
      ) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      onConnect();
    } else if (connectivityResult == ConnectivityResult.wifi) {
      onConnect();
    } else {
      onDisconnect();
    }
  }

  static Future<bool> isNetworkConnected() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult == ConnectivityResult.mobile
        || connectivityResult == ConnectivityResult.wifi;
  }

  static Future<bool> isNetworkDisconnected() async {
    return !(await isNetworkConnected());
  }
}