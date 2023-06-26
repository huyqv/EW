import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/member.dart';

import '../../utils/utils.dart';

final homeProvider = AutoDisposeChangeNotifierProvider<HomeVM>((ref) {
  return HomeVM();
});

class HomeVM extends ChangeNotifier {
  String? appBarTitle;
  List<Door> doorList = [];
  List<Member> memberListByDoor = [];
  List<Member> memberList = [];
  List<History> allHistories = [];
  List<History> allHistoriesWarning = [];
  List<History> histories = [];
  List<History> historiesWarning = [];
  Door? selectedDoor;
  Member? selectedMember;
  int indexHistorySelected = 0;
  bool isListenedHistory = false;
  StreamSubscription<DatabaseEvent>? _historySubscription;
  StreamSubscription<DatabaseEvent>? _doorListSubscription;
  StreamSubscription<DatabaseEvent>? _memberListSubscription;
  StreamSubscription<DatabaseEvent>? _historyWarningSubscription;

  Future<void> listenDoorList() async {
    await _doorListSubscription?.cancel();
    _doorListSubscription = null;
    _doorListSubscription =
        await FirebaseUtil.listenDoorList((firebaseDoors) async {
      await syncDoorList(firebaseDoors);
      syncMemberListByDoor();
      notifyListeners();
    });
  }

  Future<void> syncDoorList(List<Door> firebaseDoors) async {
    doorList = [];
    List<Door> localDoors = await getDoorList() ?? [];
    for (var e1 in firebaseDoors) {
      localDoors.removeWhere((e2) => e1.serial == e2.serial);
    }
    if (localDoors.isNotEmpty) {
      doorList.addAll(localDoors);
    }
    if (firebaseDoors.isNotEmpty) {
      doorList.addAll(firebaseDoors);
    }
    doorList.sort((a, b) => a.orderId.compareTo(b.orderId));
    if (doorList.isEmpty) {
      setSelectedDoor(null);
      return;
    }
    if (selectedDoor == null) {
      setSelectedDoor(doorList.first);
      return;
    }
    for (var element in doorList) {
      if (element.serial == selectedDoor?.serial) {
        setSelectedDoor(element);
        return;
      }
    }
  }

  void listenMemberList() async {
    await _memberListSubscription?.cancel();
    _memberListSubscription = null;
    _memberListSubscription = await FirebaseUtil.listenMemberList((members) {
      memberList = members;
      syncMemberListByDoor();
      syncHistory(allHistories);
      syncHistoryWarning(allHistoriesWarning);
      notifyListeners();
    });
  }

  Future<void> listenHistoryList(String doorId) async {
    await _historySubscription?.cancel();
    _historySubscription = null;
    _historySubscription =
        await FirebaseUtil.listenHistoryByDoorHome(doorId, (list) {
      allHistories = list;
      allHistories.sort((a, b) => b.time.compareTo(a.time));
      syncHistory(list);
      notifyListeners();
    }, (warningList) {
      allHistoriesWarning = warningList;
      allHistoriesWarning.sort((a, b) => b.time.compareTo(a.time));
      syncHistoryWarning(warningList);
      notifyListeners();
    });
  }

  void listenHistoryWarning(void Function(History) onWarning) async {
    _historyWarningSubscription?.cancel();
    _historyWarningSubscription = null;
    _historyWarningSubscription =
        await FirebaseUtil.listenHistoryWarning(onWarning);
  }

  void setAppBarTitle(String? title) {
    appBarTitle = title;
    notifyListeners();
  }

  void setSelectedDoor(Door? door) {
    if (door == null) {
      return;
    }
    selectedDoor = null;
    for (var element in doorList) {
      if (element.serial == door.serial) {
        selectedDoor = door;
        element.isSelected = true;
      } else {
        element.isSelected = false;
      }
    }
    listenHistoryList(door.serial);
    syncMemberListByDoor();
    notifyListeners();
  }

  void onHistorySelected(int index) {
    indexHistorySelected = index;
    notifyListeners();
  }

  void syncMemberListByDoor() {
    if (doorList.isEmpty) {
      return;
    }
    if (selectedDoor == null) {
      return;
    }
    memberListByDoor.clear();
    for (var member in memberList) {
      var doorMembers = selectedDoor?.members;
      if (doorMembers == null || doorMembers.isEmpty) {
        continue;
      }
      if (doorMembers.any((element) => element.id == member.userId)) {
        memberListByDoor.add(member);
      }
    }
  }

  void syncHistory(List<History> list) {
    histories = [];
    for (var history in list) {
      history.doorObj = selectedDoor;
      for (var member in memberList) {
        if (member.userId == history.userId) {
          history.userObj = member;
          break;
        }
      }
      if (history.isSuccess()) {
        if (history.userObj != null &&
            history.doorObj != null &&
            histories.length < 10) {
          histories.add(history);
        }
      }
    }
    histories.sort((a, b) => b.time.compareTo(a.time));
  }

  void syncHistoryWarning(List<History> list) {
    historiesWarning = [];
    for (var history in list) {
      history.doorObj = selectedDoor;
      for (var member in memberList) {
        if (member.userId == history.userId) {
          history.userObj = member;
          break;
        }
      }
      if (history.doorObj != null && historiesWarning.length < 10) {
        historiesWarning.add(history);
      }
      if (historiesWarning.length == 10) {
        break;
      }
    }
    historiesWarning.sort((a, b) => b.time.compareTo(a.time));
  }

  Future<void> openDoor({
    required Door door,
    required void Function() onSuccess,
    required void Function(String) onError,
  }) async {
    var isOpen = false;
    if (await Utils.isNetworkDisconnected()) {
      onError("Không có kết nối internet");
      return;
    }
    FirebaseUtil.listenDoorOpen(door, () {
      isOpen = true;
      onSuccess();
    });

    FirebaseUtil.openDoor(door.serial)
        .onError((error, stackTrace) => onError(error.toString()));
    await Future.delayed(Duration(milliseconds: 4000));
    if (!isOpen) {
      var s = 'SmartDoor ${door.getDisplayName()} không phản hồi, vui lòng kiểm tra kết nối internet';
      onError(s);
    }
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await _historySubscription?.cancel();
      await _doorListSubscription?.cancel();
      await _memberListSubscription?.cancel();
      await _historyWarningSubscription?.cancel();

      _historySubscription = null;
      _doorListSubscription = null;
      _memberListSubscription = null;
      _historyWarningSubscription = null;

    });
    super.dispose();
  }
}
