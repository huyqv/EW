import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/user.dart';
import 'package:sample/ui/vm/base_vm.dart';
import 'package:sample/utils/utils.dart';

import '../../data/pref.dart';
import '../../model/door.dart';

enum SOCKET_STATE { disconnected, connecting, connected }

var doorProvider = ChangeNotifierProvider<DoorVM>(
  (ref) {
    return DoorVM();
  },
);

class DoorVM extends BaseVM   {
  String doorName = '';
  String doorAddress = '';
  bool isLoading = false;
  String errorMessage='';
  List<String> doorSuggestName = [
    "Nhà của tôi",
    "Văn phòng",
    "Nhà hàng",
    "Sân sau",
    "Phòng làm việc",
    "Phòng ngủ",
    "Phòng khách"
  ];

  @override
  void dispose() {
    isLoading = false;
    errorMessage = '';
    notifyListeners();
    super.dispose();
  }

  Future<void> connectDoor({
    required String ssid,
    required String password,
    required String doorName,
    required Account user,
    required void Function(bool isSuccess) onCompleted,
  }) async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();
    var info = NetworkInfo();
    doorAddress = await info.getWifiGatewayIP() ?? '';
    notifyListeners();
    var map = {
      'ssid': ssid,
      'password': password,
      'doorName': doorName,
      'token': user.doorToken,
      'deviceId': 'testDeviceId',
      'phone': user.phone,
    };
    try {
      var result = await httpPostRequest(
        ip: doorAddress,
        path: 'connect',
        body: map,
      );
      if (result == null) {
        //TODO: toast failure
        isLoading = false;
        notifyListeners();
        return;
      }
      var error = result['error'];
      if (error != null && error.toString().contains('reset by peer')) {
        connectDoor(
          ssid: ssid,
          password: password,
          doorName: doorName,
          user: user,
          onCompleted: onCompleted,
        );
        return;
      }
      if (error != null) {
        errorMessage = error;
        isLoading = false;
        notifyListeners();
        return;
      }
      Future.delayed(const Duration(milliseconds: 1000), () async {
        var replyResult = await httpPostRequest(
          ip: doorAddress,
          path: 'confirm',
          body: {
            'code': 0,
            'message': 'ok',
          },
        );
        insertDoor(result.toString());
        isLoading = false;
        notifyListeners();
        onCompleted(true);
      });
    } catch (e) {
      //TODO: toast failure
      isLoading = false;
      notifyListeners();
    }
  }

  void insertDoor(String message) async {
    dynamic res = json.decode(message);
    String? doorName = res['doorName'];
    String? doorSerial = res['doorSerial'];
    if (doorName == null || doorSerial == null) {
      return;
    }
    List<Door> oldList = await getDoorList() ?? [];
    if (oldList.isNotEmpty) {
      oldList.removeWhere((item) => item.serial == doorSerial);
    }
    oldList.add(Door(
      isConnected: false,
      createTime: DateTime.now().millisecondsSinceEpoch,
      serial: doorSerial,
      name: doorName,
    ));
    setDoorList(oldList);
  }

  Future<void> updateDoorName(Door door, String name,
      {required VoidCallback onSuccess, required VoidCallback onError}) async {
    if (await Utils.isNetworkDisconnected()) {
      onError();
      return;
    }
    await FirebaseUtil.updateDoorName(door.serial, name)
        .then((value) => onSuccess())
        .onError((error, stackTrace) => onError());
  }

  Future<void> deleteDoor(Door door, List<History> histories,
      {required VoidCallback onSuccess, required VoidCallback onError}) async {
    if (await Utils.isNetworkDisconnected()) {
      onError();
      return;
    }
    await FirebaseUtil.deleteDoor(door.serial, histories)
        .then((value) => onSuccess())
        .onError((error, stackTrace) => onError());
  }
}
