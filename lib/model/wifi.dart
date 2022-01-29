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

  Wifi.fromJson(Map<String, dynamic> json)
      : ssid = json['SSID'],
        bssid = json['BSSID'],
        capabilities = json['capabilities'],
        frequency = json['frequency'],
        level = json['level'],
        timestamp = json['timestamp'];

  Map<String, dynamic> toJson() => {
    'SSID': ssid,
    'BSSID': bssid,
    'capabilities': capabilities,
    'frequency': frequency,
    'level': level,
    'timestamp': timestamp,
  };

  static List<Wifi> parse(String psString) {
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
}