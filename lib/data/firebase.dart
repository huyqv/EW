import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:camera/camera.dart';
//import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sample/data/pref.dart';
import 'package:sample/firebase_options.dart';
import 'package:sample/model/history.dart';
import 'package:sample/model/member.dart';
import 'package:sample/utils/utils.dart';

import '../model/door.dart';
import '../model/user.dart';

class FirebaseUtil {
  FirebaseUtil._internal();

  static String fcmToken = '';
  static String installationId = '';

  static Future<void> init() async {
    await initFirebaseApp();
    //await initFCMService();
  }

  static Future<void> initFirebaseApp() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform
        // options: const FirebaseOptions(
        //     apiKey: "AIzaSyCmpCKmueOk1T6U1yGhMM0SvD_ONpafevA",
        //     appId: "1:527371630974:android:ab14ab53a1d8c1db3d5b2f",
        //     messagingSenderId: '527371630974',
        //     projectId: "eurowindow-a5688",
        //     storageBucket: "gs://eurowindow-a5688.appspot.com/",
        //     databaseURL:
        //         "https://eurowindow-a5688-default-rtdb.asia-southeast1.firebasedatabase.app"),
        );

    //installationId = await FirebaseInstallations.instance.getId();
    FirebaseDatabase.instance.setPersistenceEnabled(false);
    dev.log('installationId: $installationId');
  }

  static Future<void> initFCMService() async {
    /*FirebaseMessaging messaging = FirebaseMessaging.instance;
    fcmToken = await messaging.getToken() ?? '';
    dev.log('FcmToken: $fcmToken');
    FirebaseMessaging.onBackgroundMessage(fcmHandle);*/
  }

  /*static Future<void> fcmHandle(RemoteMessage message) async {
    dev.log('Got a message whilst in the foreground!');
    dev.log('Message data: ${message.data}');
    if (message.notification != null) {
      dev.log('Message also contained a notification: ${message.notification}');
    }
  }*/

  static Future<UserCredential> loginWithToken(String token) async {
    UserCredential credential =
        await FirebaseAuth.instance.signInWithCustomToken(token);
    return credential;
  }

  static var isTest = false;

  static Future<DatabaseReference?> dataRef() async {
    if (isTest) {
      return FirebaseDatabase.instance.ref('0999999999');
    }
    Account? account = await getUser();
    if (account == null) return null;
    String phone = account.phone;
    return FirebaseDatabase.instance.ref(phone);
    //String uid = FirebaseAuth.instance.currentUser!.uid;
    //return FirebaseDatabase.instance.ref('users').child(uid);
  }

  static Future<Reference?> storageRef() async {
    if (isTest) {
      return FirebaseStorage.instance.ref('0999999999');
    }
    Account? account = await getUser();
    if (account == null) return null;
    String phone = account.phone;
    return FirebaseStorage.instance.ref(phone);
    //String uid = FirebaseAuth.instance.currentUser!.uid;
    //return FirebaseStorage.instance.ref('users').child(uid);
  }

  static Future<void> setFaceUrl(
    String url,
    String memberId,
    String userName,
  ) async {
    var ref = await dataRef();
    final task = ref?.child("members").child(memberId).set({
      "userId": memberId,
      "userPhoto": url,
      "userName": userName,
      "lastUpdate": DateTime.now().millisecondsSinceEpoch,
      "isBlocked": false
    });
    return task;
  }

  static Future<void> setAccessMember(
    List<Door> doors,
    String memberId,
  ) async {
    var internalDoor = [];
    for (var door in doors) {
      var newDoor = Door(
          isConnected: door.isConnected,
          createTime: door.createTime,
          serial: door.serial,
          name: door.name,
          isSelected: door.isSelected);
      internalDoor.add(newDoor);
    }
    var ref = await dataRef();
    for (var door in internalDoor) {
      var memberRef = ref?.child("doors/${door.serial}/members/$memberId");
      if (door.isSelected) {
        memberRef?.update({'id': memberId, 'active': false});
      } else {
        memberRef?.remove();
      }
    }
  }

  static Future<void> updateAccessMembers(
    List<Door> doors,
    String memberId,
  ) async {
    var internalDoor = [];
    for (var door in doors) {
      var newDoor = Door(
          isConnected: door.isConnected,
          createTime: door.createTime,
          serial: door.serial,
          name: door.name,
          isSelected: door.isSelected);
      internalDoor.add(newDoor);
    }
    var ref = await dataRef();
    for (var door in internalDoor) {
      if (door.isSelected) {
        var member = {'id': memberId, 'active': false};
        ref?.child("doors/${door.serial}/members/$memberId").update(member);
      }
    }
  }

  static Future<void> updateAccessMember(
    Door door,
    String memberId,
  ) async {
    var ref = await dataRef();
    var member = {'id': memberId, 'active': false};
    ref?.child("doors/${door.serial}/members/$memberId").update(member);
  }

  static Future<void> setAccessMemberList(
    Door door,
    List<Member> members,
  ) async {
    Map<String, dynamic> map = {};
    for (var member in members) {
      if (member.isSelected) {
        var obj = {'id': member.userId, 'active': false};
        map.addAll({member.userId: obj});
      }
    }
    var ref = await dataRef();
    await ref?.child("doors/${door.serial}/members").set(map);
  }

  static Future<void> updateAccessMemberList(
    Door door,
    List<Member> members,
  ) async {
    Map<String, dynamic> map = {};
    for (var member in members) {
      if (member.isSelected) {
        var obj = {'id': member.userId, 'active': false};
        map.addAll({member.userId: obj});
      }
    }
    var ref = await dataRef();
    await ref?.child("doors/${door.serial}/members").update(map);
  }

  static Future<UploadTask?> _uploadFile(
    XFile file,
    String fileName,
  ) async {
    if (file == null) {
      return null;
    }

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    final uploadTask = (await storageRef())
        ?.child("members")
        .child("$fileName.jpg")
        .putFile(File(file.path), metadata);

    return Future.value(uploadTask);
  }

  static Future<String?> uploadFileAndGetUrl(
    XFile file,
    String fileName,
  ) async {
    var task = await _uploadFile(file, fileName);
    if (task == null) {
      return null;
    }
    var link = '';
    await task
        .then((snapshot) async => link = await _downloadLink(snapshot.ref));
    return link;
  }

  static Future<void> setWarningSetting(
    Door door,
    DoorWarning warning,
  ) async {
    var ref = await dataRef();
    if (warning.value > 0) {
      var configSnapshot =
          await FirebaseDatabase.instance.ref('configs/warningDefault').get();
      warning.value = configSnapshot.value as int;
    }
    var warningRef = ref?.child('doors/${door.serial}/warning');
    warningRef?.set({'type': warning.type, 'value': warning.value});
  }

  static Future<String> _downloadLink(Reference ref) async {
    final link = await ref.getDownloadURL();
    return link;
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenDoorList(
      Function(List<Door>) onListen) async {
    var ref = await dataRef();
    return ref?.child("doors").onValue.listen(
      (DatabaseEvent event) {
        List<Door> list = [];
        final snapshotValue = event.snapshot.value;
        if (snapshotValue != null && snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            var info = values?['info'];
            if (info is Map<dynamic, dynamic>) {
              try {
                var door = Door(
                  isConnected: true,
                  createTime: info['createTime'],
                  serial: info['serial'],
                  name: info['name'],
                  members: getMembers(values["members"]),
                );
                door.displayName = values["displayName"] ?? '';
                door.orderId = values["orderId"] ?? 0;
                var warning = values?['warning'];
                door.warning = DoorWarning(
                  type: warning?['type'] ?? 'default',
                  value: warning?['value'] ?? 30,
                );
                list.add(door);
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onListen(list);
      },
    );
  }

  static List<DoorMember> getMembers(dynamic members) {
    var list = List<DoorMember>.empty(growable: true);

    if (members is Map<dynamic, dynamic>) {
      members.forEach((key, values) {
        if (values is Map<dynamic, dynamic>) {
          try {
            var doorMember = DoorMember.fromJson(values);
            list.add(doorMember);
          } catch (e) {}
        }
      });
    }
    return list;
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenDoorOpen(
      Door door, Function onListen) async {
    var ref = await dataRef();
    var openRef = ref?.child("doors/${door.serial}/opened");
    return openRef?.onValue.listen(
      (DatabaseEvent event) {
        bool isOpened = event.snapshot.value == true;
        if (isOpened) {
          onListen();
          openRef.set(false);
          openRef.onValue.listen(null);
        }
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenMemberList(
      void Function(List<Member>) onListen) async {
    var ref = await dataRef();
    return ref?.child("members").onValue.listen(
      (DatabaseEvent event) {
        List<Member> list = [];
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            if (values is Map<dynamic, dynamic>) {
              try {
                list.add(Member(
                  userId: values["userId"],
                  userName: values["userName"],
                  userPhoto: values["userPhoto"],
                  lastUpdate: values["lastUpdate"],
                  isBlocked: values["isBlocked"] ?? false,
                ));
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onListen(list);
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenMember(
      String id, void Function(Member?) onListen) async {
    var ref = await dataRef();
    return ref?.child("members/$id").onValue.listen((DatabaseEvent event) {
      Member? member;
      final value = event.snapshot.value;
      if (value is Map<dynamic, dynamic>) {
        try {
          member = Member(
            userId: value["userId"],
            userName: value["userName"],
            userPhoto: value["userPhoto"],
            lastUpdate: value["lastUpdate"],
            isBlocked: value["isBlocked"] ?? false,
          );
        } catch (e) {
          dev.log(e.toString());
        }
      }
      onListen(member);
    });
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenHistoryByStatus(
      {String status = "success",
      required void Function(List<History>) onListen}) async {
    var ref = await dataRef();
    return ref
        ?.child("history")
        .orderByChild("status")
        .equalTo(status)
        .onValue
        .listen(
      (DatabaseEvent event) {
        List<History> list = [];
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            if (values is Map<dynamic, dynamic>) {
              try {
                list.add(History(values["door"], values["image"],
                    values["status"], values["time"], values["userId"]));
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onListen(list);
      },
    );
  }

  static Future<void>? getHistoryByStatus(
      {String status = "success",
      required void Function(List<History>) onListen}) async {
    var ref = await dataRef();
    var snapshotValue = await ref
        ?.child("history")
        .orderByChild("status")
        .equalTo(status)
        .once(DatabaseEventType.value);
    List<History> list = [];
    var value = snapshotValue?.snapshot.value;
    if (value is Map<dynamic, dynamic>) {
      value.forEach((key, values) {
        if (values is Map<dynamic, dynamic>) {
          try {
            list.add(History(
              values["door"],
              values["image"],
              values["status"],
              values["time"],
              values["userId"],
            ));
          } catch (e) {
            dev.log(e.toString());
          }
        }
      });
    }
    onListen(list);
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenHistoryByDoorHome(
    String doorId,
    void Function(List<History>) onHistoryList,
    void Function(List<History>) onHistoryWarningList,
  ) async {
    var ref = await dataRef();
    return ref
        ?.child("history")
        .orderByChild("door")
        .equalTo(doorId)
        .onValue
        .listen(
      (DatabaseEvent event) {
        List<History> list = List.empty(growable: true);
        List<History> listWarning = List.empty(growable: true);
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            if (values is Map<dynamic, dynamic>) {
              try {
                if (values["status"] == "success") {
                  list.add(History(values["door"], values["image"],
                      values["status"], values["time"], values["userId"]));
                } else {
                  listWarning.add(History(values["door"], values["image"],
                      values["status"], values["time"], values["userId"]));
                }
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onHistoryList(list);
        onHistoryWarningList(listWarning);
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenHistoryByDoor(
    String doorId,
    void Function(List<History>) onHistoryList,
    void Function(List<History>) onHistoryWarningList,
  ) async {
    var ref = await dataRef();
    return ref
        ?.child("history")
        .orderByChild("door")
        .equalTo(doorId)
        .onValue
        .listen(
      (DatabaseEvent event) {
        List<History> list = List.empty(growable: true);
        List<History> listWarning = List.empty(growable: true);
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            if (values is Map<dynamic, dynamic>) {
              try {
                if (values["status"] == "success") {
                  list.add(History(values["door"], values["image"],
                      values["status"], values["time"], values["userId"]));
                } else {
                  listWarning.add(History(values["door"], values["image"],
                      values["status"], values["time"], values["userId"]));
                }
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onHistoryList(list);
        onHistoryWarningList(listWarning);
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> listenHistoryWarning(
    void Function(History) onListen,
  ) async {
    var ref = await dataRef();
    return ref
        ?.child("history")
        .orderByChild("status")
        .equalTo("failure")
        .onChildAdded
        .listen(
      (DatabaseEvent event) {
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          try {
            int time = snapshotValue["time"];
            var date = DateTime.fromMillisecondsSinceEpoch(time);
            var duration = DateTime.now().difference(date);
            if (duration.inSeconds < 10) {
              var history = History(
                  snapshotValue["door"],
                  snapshotValue["image"],
                  snapshotValue["status"],
                  snapshotValue["time"],
                  snapshotValue["userId"]);
              if (history.userId.isEmpty) {
                onListen(history);
              }
            }
          } catch (e) {
            dev.log(e.toString());
          }
        }
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> getAccessMember(
      Door door, void Function(List<DoorMember>) onListen) async {
    var ref = await dataRef();
    return ref?.child("doors/${door.serial}/members").onValue.listen(
      (DatabaseEvent event) {
        final snapshotValue = event.snapshot.value;
        List<DoorMember> members = getMembers(snapshotValue);
        onListen(members);
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> filterDoorMemberCanAccess(
      String userId, void Function(List<Door>) onListen) async {
    var ref = await dataRef();
    return ref?.child("doors").onValue.listen(
      (DatabaseEvent event) {
        List<Door> doors = [];
        final snapshotValue = event.snapshot.value;
        if (snapshotValue is Map<dynamic, dynamic>) {
          snapshotValue.forEach((key, values) {
            var members = values["members"];
            var info = values?['info'];
            var memberIsAccept = false;
            if (members is Map<dynamic, dynamic>) {
              members.forEach((key, values) {
                if (key == userId) {
                  memberIsAccept = true;
                }
              });
            }
            if (memberIsAccept &&
                info != null &&
                info is Map<dynamic, dynamic>) {
              try {
                if (info["name"] != null && info["name"] != "") {
                  doors.add(Door(
                    isConnected: true,
                    createTime: info['createTime'],
                    serial: info['serial'],
                    name: info['name'],
                  ));
                }
              } catch (e) {
                dev.log(e.toString());
              }
            }
          });
        }
        onListen(doors);
      },
    );
  }

  static Future<StreamSubscription<DatabaseEvent>?> filterMemberHistory(
      String userId, void Function(List<History>) onListen) async {
    var ref = await dataRef();
    return ref
        ?.child("history")
        .orderByChild("userId")
        .equalTo(userId)
        .onValue
        .listen((event) {
      List<History> histories = [];
      final snapshotValue = event.snapshot.value;
      if (snapshotValue is Map<dynamic, dynamic>) {
        snapshotValue.forEach((key, values) {
          if (values is Map<dynamic, dynamic>) {
            try {
              histories.add(History(values["door"], values["image"],
                  values["status"], values["time"], values["userId"]));
            } catch (e) {
              dev.log(e.toString());
            }
          }
        });
      }
      onListen(histories);
    });
  }

  static Future<void> deleteMember(String id, List<Door> doors) async {
    List<Door> listDoor = List.empty(growable: true);
    for (var door in doors) {
      listDoor.add(Door.initDoor(door));
    }
    var ref = await dataRef();
    await ref?.child("members/$id").remove();
    for (var door in listDoor) {
      await ref?.child("doors/${door.serial}/members/$id").remove();
    }
  }

  static Future<void> setBlockMember(String id, bool isBlock) async {
    var ref = await dataRef();
    await ref?.child("members/$id").update({"isBlocked": isBlock});
  }

  void iOSPermission() {}

  static Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
  }

  static Future<void> openDoor(String doorId) async {

    var now = DateTime.now().millisecondsSinceEpoch;
    var ref = await dataRef();
    return await ref
        ?.child("doors")
        .child(doorId)
        .child("openByAppTime")
        .set(now);
  }

  static Future<void> updateDoorName(String doorId, String doorName) async {

    var now = DateTime.now().millisecondsSinceEpoch;
    var ref = await dataRef();
    return await ref?.child("doors/$doorId").update({"displayName": doorName});
  }

  static Future<void> deleteDoor(String id, List<History> histories) async {
    var ref = await dataRef();
    List<History> list = List.empty(growable: true);
    await ref?.child("doors/$id").remove();
    for (var history in histories) {
      list.add(History.init(history));
    }
    for (var history in list) {
      if (history.door == id) {
        await ref?.child("history/${history.time}").remove();
      }
    }
  }
}
