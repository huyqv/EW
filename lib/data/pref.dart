import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sample/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/door.dart';

final prefProvider = Provider<Pref>((ref) => throw UnimplementedError());

Future<Override> prefProviderOverride() async {
  return prefProvider.overrideWithValue(
    Pref(await SharedPreferences.getInstance()),
  );
}

class Pref {
  Pref(this.pref);

  final SharedPreferences pref;

  static const onBoardingCompleteKey = 'onBoardingComplete';
  static const userKey = 'userKey';
  static const doorKey = 'doorKey';

  Future<void> setOnBoardingComplete() async {
    await pref.setBool(onBoardingCompleteKey, true);
  }

  bool isOnBoardingComplete() => pref.getBool(onBoardingCompleteKey) ?? false;

  Future<void> setUser(Account? user) async {
    if (user == null) {
      await pref.remove(userKey);
      return;
    }
    String rawJson = jsonEncode(user.toJson());
    await pref.setString(userKey, rawJson);
  }

  Account? getUser() {
    var rawJson = pref.getString(userKey);
    if (rawJson != null) {
      Map<String, dynamic> map = jsonDecode(rawJson);
      return Account.fromMap(map);
    }
    return null;
  }
}

Future<void> setDoorList(List<Door> list) async {
  final String encodedData = Door.encode(list);
  final pref = await SharedPreferences.getInstance();
  await pref.setString(Pref.doorKey, encodedData);
}

Future<List<Door>?> getDoorList() async {
  try {
    final pref = await SharedPreferences.getInstance();
    final String? s = pref.getString(Pref.doorKey);
    if (s == null || s.isEmpty) {
      return [];
    }
    return Door.decode(s);
  } catch (e) {
    return [];
  }
}

Future<void> setUser(Account? user) async {
  final pref = await SharedPreferences.getInstance();
  if (user == null) {
    await pref.remove(Pref.userKey);
    return;
  }
  String rawJson = jsonEncode(user.toJson());
  await pref.setString(Pref.userKey, rawJson);
}

Future<Account?> getUser() async {
  try {
    final pref = await SharedPreferences.getInstance();
    var rawJson = pref.getString(Pref.userKey);
    if (rawJson != null) {
      Map<String, dynamic> map = jsonDecode(rawJson);
      return Account.fromMap(map);
    }
  } catch (e) {
    return null;
  }
  return null;
}
