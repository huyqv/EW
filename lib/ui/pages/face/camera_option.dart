
import 'dart:io';

import 'package:camera/camera.dart';

class CameraOption {
  CameraOption._internal();

  static Future<CameraController> getCameraController(CameraDescription camera) async {
    ResolutionPreset res = Platform.isAndroid ? ResolutionPreset.max : ResolutionPreset.veryHigh;
    var controller = CameraController(
      camera,
      res,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );
    await controller.initialize();
    await controller.setFlashMode(FlashMode.off);
    await controller.setFocusMode(FocusMode.auto);
    await controller.setExposureMode(ExposureMode.auto);
    return controller;
  }

}
