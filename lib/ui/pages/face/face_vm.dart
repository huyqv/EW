import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:permission_handler/permission_handler.dart';
import 'package:sample/data/firebase.dart';
import 'package:sample/model/door.dart';
import 'package:sample/ui/pages/face/face_painter.dart';

import '../../../data/pref.dart';
import '../../../main.dart';
import '../../../model/user.dart';
import '../../../utils/camera.dart';
import '../../../utils/permission.dart';
import '../../vm/base_vm.dart';
import 'camera_option.dart';
import 'face_option.dart';

class FaceVM extends BaseVM {
  bool isSwitching = false;
  bool hasFace = false;
  bool isFaceProcessing = false;
  bool isCapturing = false;
  bool isLoading = false;
  int cameraIndex = 0;
  String message = '';
  Uint8List? capturedImage;
  Uint8List? uploadImage;
  CameraLensDirection cameraLens = CameraLensDirection.front;
  CameraController? controller;
  CameraDescription? camera;
  CustomPaint? customPaint;
  bool isStarted = false;

  Future<void> init() async {
    requestPermission(Permission.camera, onGranted: () async {
      Future.delayed(Duration(milliseconds: 200));
      await startCamera();
      camPermission = PermissionStatus.granted;
      notifyListeners();
    }, onDenied: () async {
      await stopCamera();
      customPaint = null;
      camPermission = PermissionStatus.denied;
      notifyListeners();
    });
  }

  bool isCameraStarted() {
    return controller != null && controller!.value.isInitialized;
  }

  bool isTakingPicture() {
    return controller != null && controller!.value.isTakingPicture;
  }

  bool isImageCaptured() {
    return capturedImage != null;
  }

  Future<void> startCamera() async {
    capturedImage = null;
    customPaint = null;
    isFaceProcessing = false;
    isCapturing = false;
    try {
      if (isCameraStarted()) {
        notifyListeners();
        return;
      }
      List<CameraDescription> cameraDescription = await availableCameras();
      for (var i = 0; i < cameraDescription.length; i++) {
        CameraDescription camera = cameraDescription[i];
        bool isColorCamera = camera.name.contains('0') || camera.name.contains('1');
        if (camera.lensDirection == cameraLens && isColorCamera) {
          cameraIndex = i;
          break;
        }
      }
      if (cameraDescription.isNotEmpty) {
        camera = cameraDescription[cameraIndex];
        if (controller != null) {
          await controller?.dispose();
        }
        controller = await CameraOption.getCameraController(camera!);
        await controller?.startImageStream((image) async {
          await _processCameraImage(image);
        });
        isStarted = true;
        notifyListeners();
        dev.log('camera started');
      }
    } on CameraException catch (e) {
      controller = null;
      isStarted = false;
      dev.log(e.toString());
      notifyListeners();
    }
  }

  Future<void> stopCamera() async {
    isStarted = false;
    try {
      if(capturedImage==null){
        await controller?.stopImageStream();
      }
    } catch (e) {
      dev.log(e.toString());
      //ignore
    }
    try {
      await controller?.lockCaptureOrientation();
      await controller?.dispose();
      controller = null;
    } catch (e) {
      dev.log(e.toString());
    }
  }

  Future<void> switchCamera() async {
    cameraLens = cameraLens == CameraLensDirection.front
        ? CameraLensDirection.back
        : CameraLensDirection.front;
    isSwitching = true;
    customPaint = null;
    notifyListeners();
    await stopCamera();
    await Future.delayed(const Duration(milliseconds: 360));
    await startCamera();
    isSwitching = false;
  }

  Future<void> captureImage() async {
    if (!isCameraStarted() || !hasFace) {
      return;
    }
    isCapturing = true;
    customPaint = null;
    notifyListeners();

    // must stop image stream before take picture
    await controller!.stopImageStream();
    XFile? image = await controller!.takePicture();
    var fullImage = await image.readAsBytes();

    imglib.Image cropImage = FaceOption.cropImage(fullImage);
    capturedImage = FaceOption.encodeImage(cropImage);

    imglib.Image resizeImage = FaceOption.resizeImage(cropImage);
    uploadImage = FaceOption.encodeImage(resizeImage);
    isStarted = false;
    notifyListeners();
    stopCamera();
  }

  Future<void> _processCameraImage(CameraImage cameraImage) async {
    if (isFaceProcessing || !isStarted) {
      return;
    }
    isFaceProcessing = true;
    final InputImageRotation imageRotation =
        InputImageRotationMethods.fromRawValue(
                camera?.sensorOrientation ?? 0) ??
            InputImageRotation.Rotation_0deg;

    InputImage currentImage = getInputImage(
      cameraImage,
      InputImageFormat.YUV420,
      imageRotation,
    );

    List<Face> faces = await FaceOption.faceDetector.processImage(currentImage);
    Face? face = FaceOption.getLargestFace(faces);
    if (kDebugMode) {
      /*customPaint = FacePainter.customPaint(
        face: face,
        imageData: currentImage.inputImageData,
      );*/
    }
    message = FaceOption.getFaceMessage(
      face: face,
      inputImage: currentImage,
    );
    hasFace = message.isEmpty;
    if (isStarted) {
      notifyListeners();
    }
    isFaceProcessing = false;
  }

  void clearData() {
    isSwitching = false;
    cameraIndex = 0;
    hasFace = false;
    isFaceProcessing = false;
    isCapturing = false;
    capturedImage = null;
  }

  Future<void> addMember(
    XFile file,
    Door door,
    String userName,
    Function(String url) onSuccess,
  ) async {
    isLoading = true;
    notifyListeners();
    var userId = DateTime.now().millisecondsSinceEpoch.toString();

    Account? user = await getUser();
    if (user == null) {
      return;
    }
    var photoBytes = Uint8List.fromList(await file.readAsBytes());
    var photoEncoded = base64Encode(photoBytes);
    var response = await postRequest(
      endpoint: 'guest/reg',
      body: {
        'reqId': user.phone,
        'cid': user.phone,
        'langCode': 'vi',
        'data': {
          'jwt': user.jwt,
          'userId': userId,
          'guestId': userId,
          'photo': photoEncoded,
        },
      },
    );
    int code = response?['code'];
    if (code == 0) {
      var downLoadUrl = await FirebaseUtil.uploadFileAndGetUrl(file, userId);
      await FirebaseUtil.setFaceUrl(downLoadUrl!, userId, userName);
      await _setAccessMember(door, userId);
      onSuccess(downLoadUrl);
    } else {
      onSuccess('');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> _setAccessMember(Door door, String userId) async {
    await FirebaseUtil.updateAccessMember(door, userId);
  }

}
