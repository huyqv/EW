import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/door.dart';
import 'package:sample/model/member.dart';

import '../../utils/utils.dart';

var addMemberProvider =
    AutoDisposeChangeNotifierProvider<AddMemberVM>((ref) => AddMemberVM());

class AddMemberVM extends ChangeNotifier {
  List<Door> doors = [];
  List<Member> members = [];
  List<Member> memberIsHadSelected = [];
  bool isMemberSelectedChange = false;
  StreamSubscription<DatabaseEvent>? _streamMemberList;
  StreamSubscription<DatabaseEvent>? _streamAccessMember;

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

  void onMemberSelected(Member member) {
    var index =
        members.indexWhere((element) => element.userId == member.userId);
    members[index].isSelected = !members[index].isSelected;
    isMemberSelectedChange = memberSelectedChanged();
    notifyListeners();
  }

  void onAllMemberSelected(bool isChecked) {
    for (var element in members) {
      element.isSelected = isChecked;
    }
    isMemberSelectedChange = memberSelectedChanged();
    notifyListeners();
  }

  Future<void> getAccessMember(Door door) async {
    if(_streamAccessMember == null) {
      _streamAccessMember = await FirebaseUtil.getAccessMember(door, (members) async {
        await listenMemberList(members);
      });
    }
  }

  Future<void> listenMemberList(List<DoorMember> doorMembers) async {
    if(_streamMemberList == null) {
      _streamMemberList = await FirebaseUtil.listenMemberList((members) async {
        this.members.clear();
        memberIsHadSelected.clear();
        for (var member in members) {
          for (var doorMember in doorMembers) {
            if (member.userId == doorMember.id) {
              member.isSelected = true;
              memberIsHadSelected.add(member);
              break;
            }
          }
          this.members.add(member);
        }
        isMemberSelectedChange = memberSelectedChanged();
        notifyListeners();
      });
    }
  }

  bool memberSelectedChanged() {
    var count = 0;
    var memberSelected = members.where((element) => element.isSelected).length;
    if(memberSelected != memberIsHadSelected.length) {
      return true;
    }
    for(var m1 in members) {
      for(var m2 in memberIsHadSelected) {
        if(m1.userId == m2.userId && m1.isSelected) {
          count +=1;
        }
      }
    }
    return count != memberIsHadSelected.length;
  }

  Future<void> setAccessMemberList(Door door) async {
    return await FirebaseUtil.setAccessMemberList(door, members);
  }

  @override
  void dispose() {
    Future.delayed(Duration.zero, () async{
      await _streamMemberList?.cancel();
      await _streamAccessMember?.cancel();
      _streamAccessMember = null;
      _streamAccessMember = null;
    });
    super.dispose();
  }
}
