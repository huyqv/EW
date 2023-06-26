import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/member.dart';
import 'package:sample/ui/vm/base_vm.dart';

var historyProvider = AutoDisposeChangeNotifierProvider((ref) => HistoryVM());

class HistoryVM extends BaseVM {
  List<History> historyList = [];
  List<History> historyWarningList = [];
  List<History> kHistoryList = [];
  List<History> kHistoryWarningList = [];
  List<Member> memberList = [];
  List<Door> doorList = [];
  Door? doorSelected;
  StreamSubscription<DatabaseEvent>? _historySubscription;

  void init(Door door) async {
    doorSelected = door;
    await getHistoryByDoor(door.serial);
  }

  Future<void> getHistoryByDoor(String id) async {
    if (_historySubscription == null) {
      _historySubscription = await FirebaseUtil.listenHistoryByDoor(id, (list) {
        kHistoryList.clear();
        historyList = list;
        _onTabSuccessSelected(historyList);
      }, (warningList) {
        kHistoryWarningList.clear();
        historyWarningList = warningList;
        _onTabFailureSelected(historyWarningList);
      });
    }
  }

  void onTabChange(int index) {
    if (historyList.isNotEmpty && index == 0) {
      onHistoryLoadMore();
    }
    if (historyWarningList.isNotEmpty && index == 1) {
      onHistoryWarningLoadMore();
    }
  }

  void _onTabSuccessSelected(List<History> list) {
    historyList = [];
    for (var history in list) {
      history.doorObj = doorSelected;
      for (var member in memberList) {
        if (member.userId == history.userId) {
          history.userObj = member;
          break;
        }
      }
      if (history.userObj != null && history.doorObj != null) {
        historyList.add(history);
      }
    }
    historyList.sort((a, b) => b.time.compareTo(a.time));
    onHistoryLoadMore();
  }

  void _onTabFailureSelected(List<History> list) {
    historyWarningList = [];
    for (var history in list) {
      history.doorObj = doorSelected;
      for (var member in memberList) {
        if (member.userId == history.userId) {
          history.userObj = member;
          break;
        }
      }
      if (history.doorObj != null) {
        historyWarningList.add(history);
      }
    }
    historyWarningList.sort((a, b) => b.time.compareTo(a.time));
    onHistoryWarningLoadMore();
  }

  void onHistoryLoadMore() {
    Future.delayed(const Duration(seconds: 1), () {
      if (kHistoryList.length + 20 <= historyList.length) {
        var loadMoreList =
            historyList.sublist(kHistoryList.length, kHistoryList.length + 20);
        kHistoryList.addAll(loadMoreList);
      } else if (kHistoryList.length + 20 > historyList.length &&
          kHistoryList.length < historyList.length) {
        var loadMoreList =
            historyList.sublist(kHistoryList.length, historyList.length);
        kHistoryList.addAll(loadMoreList);
      }
      notifyListeners();
    });
  }

  void onHistoryWarningLoadMore() {
    Future.delayed(const Duration(seconds: 1), () {
      if (kHistoryWarningList.length + 20 <= historyWarningList.length) {
        var loadMoreList = historyWarningList.sublist(
            kHistoryWarningList.length, kHistoryWarningList.length + 20);
        kHistoryWarningList.addAll(loadMoreList);
      } else if (kHistoryWarningList.length + 20 > historyWarningList.length &&
          kHistoryWarningList.length < historyWarningList.length) {
        var loadMoreList = historyWarningList.sublist(
            kHistoryWarningList.length, historyWarningList.length);
        kHistoryWarningList.addAll(loadMoreList);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async {
      await _historySubscription?.cancel();
    });
    super.dispose();
  }
}
