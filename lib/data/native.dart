import 'dart:developer' as dev;
import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:sample/model/wifi.dart';

class Native {
  Native._internal();

  static const MethodChannel channel = MethodChannel('wee.dev.ewa/flutter');

  static Future<void> showToast(String message) async {
    var arg = <String, dynamic>{'message': message};
    await channel.invokeMethod('showToast', arg);
  }

  static Future<void> wifiEnable(bool isEnable) async {
    if (Platform.isIOS) {
      return;
    }
    dynamic arg = <String, dynamic>{'isEnable': isEnable.toString()};
    await channel.invokeMethod('wifiEnable', arg);
  }

  static Future<bool> isWifiEnabled() async {
    try {
      if (Platform.isIOS) {
        return false;
      }
      bool result = await channel.invokeMethod('isWifiEnabled');
      return result;
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return false;
    }
  }

  static Future<bool> wifiListen(bool currentEnable) async {
    try {
      if (Platform.isIOS) {
        return false;
      }
      dynamic arg = <String, dynamic>{'isEnable': currentEnable.toString()};
      bool result = await channel.invokeMethod('wifiListen', arg);
      return result;
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return false;
    }
  }

  static Future<List<Wifi>> wifiScan() async {
    if (Platform.isIOS) {
      return [];
    }
    try {
      String? result = await channel.invokeMethod('wifiScan');
      return Wifi.parseList(result!);
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return [];
    }
  }

  static Future<bool> connect(
      {required String ssid, required String password}) async {
    dynamic arg = <String, dynamic>{'ssid': ssid, 'password': password};
    try {
      bool result = await channel.invokeMethod('wifiConnect', arg);
      return result;
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return false;
    }
  }

  static Future<void> startWifiAP() async {
    if (Platform.isIOS) {
      return;
    }
    await channel.invokeMethod('startWifiAP');
  }

  static Future<Wifi?> currentWifi() async {
    if (Platform.isIOS) {
      return null;
    }
    try {
      String? result = await channel.invokeMethod('currentWifi');
      return Wifi.parse(result!);
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return null;
    }
  }

  static Future<String?> request(String url, String body) async {
    try {
      dynamic arg = <String, dynamic>{
        'isEnable': url,
        'body': body,
      };
      String? result = await channel.invokeMethod('request', arg);
      return result;
    } on MissingPluginException catch (e) {
      dev.log(e.message ?? e.toString());
      return null;
    }
  }
}
