import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

example() {
  requestPermission(Permission.location, onGranted: () async {}, onDenied: () {
    //alertMessage(context, message: "Location permission require to scan");
  });
}

requestPermission(
  Permission permission, {
  required VoidCallback onGranted,
  VoidCallback? onDenied,
}) async {
  await requestPermissions(
    [permission],
    onGranted: onGranted,
    onDenied: onDenied,
  );
}

requestPermissions(
  List<Permission> permissions, {
  required VoidCallback onGranted,
  VoidCallback? onDenied,
}) async {
  List<Permission> deniedPermission = [];
  Map<Permission, PermissionStatus> statuses = await permissions.request();
  for (var element in permissions) {
    var status = statuses[element];
    if (status == null) {
      deniedPermission.add(element);
      continue;
    }
    if (status.isGranted) {
      continue;
    } else {
      deniedPermission.add(element);
    }
    // if (status.isDenied) {
    //   deniedPermission.add(element);
    //   continue;
    // }
    // if (Platform.isAndroid && status.isPermanentlyDenied) {
    //   deniedPermission.add(element);
    //   continue;
    // }
    // if (Platform.isIOS && await element.isRestricted) {
    //   deniedPermission.add(element);
    //   continue;
    // }
    // if (await element.isLimited) {
    //   deniedPermission.add(element);
    //   continue;
    // }
  }
  if (deniedPermission.isEmpty) {
    onGranted.call();
  } else {
    onDenied?.call();
  }
}
