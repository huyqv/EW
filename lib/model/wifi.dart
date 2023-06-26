import 'dart:convert';
import 'dart:developer' as dev;

class Wifi {
  String? ssid;
  String? bssid;
  String? capabilities;
  int? frequency;
  int? level;
  int? timestamp;
  String? password;
  bool isConnected = false;

  Wifi();

  Wifi.fromJson(Map<String, dynamic> json)
      : ssid = json['ssid'],
        bssid = json['bssid'];

  Map<String, dynamic> toJson() => {
    'ssid': ssid,
    'bssid': bssid,
  };

  static List<Wifi> parseList(String psString) {
    final List<Wifi> htList = <Wifi>[];
    try {
      final List<dynamic> htMapNetworks = json.decode(psString);
      for (var htMapNetwork in htMapNetworks) {
        htList.add(Wifi.fromJson(htMapNetwork));
      }
    } catch (e) {
      dev.log(e.toString());
    }
    return htList;
  }

  static Wifi? parse(String psString) {
    try {
      final dynamic htMapNetworks = json.decode(psString);
      return Wifi.fromJson(htMapNetworks);
    } catch (e) {
      dev.log(e.toString());
    }
    return null;
  }

  @override
  bool operator ==(Object other) {
    return (other is Wifi) && other.ssid == ssid && other.bssid == bssid;
  }

  @override
  int get hashCode => super.hashCode;

}