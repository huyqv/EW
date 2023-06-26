import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/door.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/member.dart';

import '../../utils/utils.dart';

var memberProvider = AutoDisposeChangeNotifierProvider<MemberVM>((ref) => MemberVM());

class MemberVM extends ChangeNotifier {
  List<Door> doorsAccepted = [];
  List<Door> doors = [];
  List<History> histories = [];
  StreamSubscription<DatabaseEvent>? _streamDoorList;
  StreamSubscription<DatabaseEvent>? _streamDoorCanAccess;
  StreamSubscription<DatabaseEvent>? _streamMemberHistory;
  Member? member;

  Future<void> filterDooCanAccess(String id) async {
    if(_streamDoorCanAccess == null) {
      _streamDoorCanAccess = await FirebaseUtil.filterDoorMemberCanAccess(id, (doors) {
        doorsAccepted.clear();
        doorsAccepted = doors;
        mergeDoors();
      });
    }
  }

  Future<void> setBlockMember() async {
    var block = member!.isBlocked;
    await FirebaseUtil.setBlockMember(member!.userId, !block);
    member!.isBlocked = !block;
    notifyListeners();
  }

  Future<void> deleteMember() async {

    await FirebaseUtil.deleteMember(member!.userId, doors);
  }

  Future<void> listenDoorList() async {
    if(_streamDoorList == null) {
      _streamDoorList = await FirebaseUtil.listenDoorList((doors) {
        this.doors.clear();
        this.doors.addAll(doors);
        mergeDoors();
        syncHistory();
      });
    }
  }

  void mergeDoors() {
    if (doors.isEmpty) {
      return;
    }
    for (var d1 in doors) {
      for (var d2 in doorsAccepted) {
        if (d1.serial == d2.serial) {
          d1.isSelected = true;
          break;
        }
      }
    }
    notifyListeners();
  }

  void onDoorSelected(Door door) {
    var index = doors.indexWhere((element) => element.serial == door.serial);
    doors[index].isSelected = !doors[index].isSelected;
    notifyListeners();
  }

  void onAllDoorSelected(bool isChecked) {
    for (var element in doors) {
      element.isSelected = isChecked;
    }
    notifyListeners();
  }

  Future<void> setAccessMember() async {
    return await FirebaseUtil.setAccessMember(doors, member!.userId);
  }

  Future<void> filterMemberHistory() async {
    if (member?.userId == null) return;
    if(_streamMemberHistory == null) {
      _streamMemberHistory = await FirebaseUtil.filterMemberHistory(member!.userId, (histories) {
        this.histories = histories;
        syncHistory();
      });
    }
  }

  void syncHistory() {
    if (histories.isEmpty) {
      return;
    }
    if (doors.isEmpty) {
      return;
    }
    for (var history in histories) {
      history.userObj = member;
      for (var door in doors) {
        if (history.door == door.serial) {
          history.doorObj = door;
          break;
        }
      }
    }
    histories.sort((a, b) => b.time.compareTo(a.time));
    notifyListeners();
  }

  @override
  void dispose() {
    doorsAccepted.clear();
    doors.clear();
    histories.clear();
    Future.delayed(Duration.zero, () async{
      await _streamDoorList?.cancel();
      await _streamDoorCanAccess?.cancel();
      await _streamMemberHistory?.cancel();
      _streamDoorList = null;
      _streamDoorCanAccess = null;
      _streamMemberHistory = null;
    });
    super.dispose();
  }
}
