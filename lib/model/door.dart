import 'dart:convert';

import 'package:sample/ui/pages/door_warning.dart';

class Door {
  bool isConnected = false;
  String name = '';
  String serial = '';
  String displayName = '';
  int orderId = 0;
  int createTime = DateTime.now().millisecondsSinceEpoch;
  List<DoorMember>? members = List.empty(growable: true);
  bool isSelected = false;
  DoorWarning warning = DoorWarning();

  Door.fromMap(Map<String, dynamic> map) {
    isConnected = map['isConnected'] ?? false;
    name = map['name'] ?? '';
    serial = map['serial'] ?? '';
    createTime = map['createTime'] ?? 0;
  }

  getDisplayName() {
    if (displayName.isNotEmpty) {
      return displayName;
    }
    if (name.isNotEmpty) {
      return name;
    }
    return 'Unknown';
  }

  Map<String, dynamic> toJson() => {
        'isConnected': isConnected,
        'createTime': createTime,
        'name': name,
        'serial': serial
      };

  Door({
    this.isConnected = false,
    this.createTime = 0,
    this.serial = '',
    this.name = '',
    this.displayName = '',
    this.isSelected = false,
    this.members,
  });

  Door.initDoor(Door door) {
    isConnected = door.isConnected;
    createTime = door.createTime;
    serial = door.serial;
    name = door.name;
    isSelected = door.isSelected;
  }

  static String encode(List<Door> list) => json.encode(
        list.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
      );

  static List<Door> decode(String musics) =>
      (json.decode(musics) as List<dynamic>)
          .map<Door>((item) => Door.fromMap(item))
          .toList();
}

class DoorMember {
  String id = '';
  bool active = false;

  DoorMember({required this.id, required this.active});

  DoorMember.fromJson(Map<dynamic, dynamic> json) {
    id = json["id"]?.toString() ?? '';
    active = json["active"] ?? false;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "active": active,
    };
  }
}

class DoorWarning {
  String type = '';
  int value = 0;

  DoorWarning({this.type = 'default', this.value = DoorWarningItem.defaultDuration});

  DoorWarning.fromJson(Map<dynamic, dynamic> json) {
    type = json["type"]?.toString() ?? '';
    value = json["value"] ?? false;
  }

  Map<String, dynamic> toJson() {

    return {
      "type": type,
      "value": value,
    };
  }

  bool isEnable() {
    return type == "default";
  }
}
