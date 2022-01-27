import 'package:flutter/services.dart';

class Native {
  Native._internal();

  static const MethodChannel channel =
      MethodChannel('com.example.sample/flutter');

  static Future<void> showToast(String message) async {
    await channel
        .invokeMethod('showToast', <String, dynamic>{'message': message});
  }

  static Future<void> wifiEnable(bool isEnable) async {
    await channel.invokeMethod(
        'wifiEnable', <String, dynamic>{'isEnable': isEnable.toString()});
  }

  static Future<bool> isWifiEnabled() async {
    return await channel.invokeMethod('isWifiEnabled') ?? false;
  }

  static Future<bool> wifiListen() async {
    try {
      return await channel.invokeMethod('wifiListen') ?? false;
    } catch (e) {
      return false;
    }
  }
}
