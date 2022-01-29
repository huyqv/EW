import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';

mixin PermissionUtil {

  requestPermission(
    Permission permission, {
    required VoidCallback onGranted,
    VoidCallback? onDenied,
  }) async {
    requestPermissions(
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
        continue;
      }
      if (status.isDenied) {
        deniedPermission.add(element);
        continue;
      }
      if (await Permission.location.isRestricted) {
        deniedPermission.add(element);
        continue;
      }
    }
    if (deniedPermission.isEmpty) {
      onGranted.call();
      return;
    }
    if (await Permission.contacts.request().isGranted) {
      onGranted.call();
      return;
    }
    if (onDenied != null) {
      onDenied.call();
    }
  }
}
