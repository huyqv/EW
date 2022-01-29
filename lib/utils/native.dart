import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:sample/model/wifi.dart';

class Native {
  Native._internal();

  static const MethodChannel channel =
      MethodChannel('com.example.sample/flutter');

  static Future<void> showToast(String message) async {
    await channel
        .invokeMethod('showToast', <String, dynamic>{'message': message});
  }

  static Future<void> wifiEnable(bool isEnable) async {
    dynamic arg = <String, dynamic>{'isEnable': isEnable};
    await channel.invokeMethod('wifiEnable', arg);
  }

  static Future<bool> isWifiEnabled() async {
    return await channel.invokeMethod('isWifiEnabled') ?? false;
  }

  static Future<List<Wifi>> wifiScan() async {
    try {
      String? result = await channel.invokeMethod('wifiScan');
      return Wifi.parse(result!);
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return [];
    }
  }

  static Future<bool> connect() async {
    dynamic arg = <String, dynamic>{'ssid': 'Huy', 'password': '23121990huy'};
    try {
      bool result = await channel.invokeMethod('wifiConnect', arg);
      return result;
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return false;
    }
  }
}
