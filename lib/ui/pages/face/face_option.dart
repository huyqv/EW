import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imgLib;

class FaceOption {
  FaceOption._internal();

  static imgLib.PngEncoder pngEncoder = imgLib.PngEncoder(level: 0, filter: 0);
  static imgLib.JpegEncoder jpegEncoder = imgLib.JpegEncoder(quality: 100);
  static const uploadWidth = 320;
  static const uploadHeight = 240;
  static const double focusViewRatio = 0.78;
  static const double focusTopPadding = 0.2;
  static const double faceWidthPercent = 0.4;
  static FaceDetector faceDetector = GoogleMlKit.vision.faceDetector(
    const FaceDetectorOptions(
      //enableTracking: true,
      //enableLandmarks: true,
      mode: FaceDetectorMode.fast,
    ),
  );
  static Face? getLargestFace(List<Face> faces) {
    if (faces.isEmpty) {
      return null;
    }
    var face = faces.reduce((value, element) {
      if (value.boundingBox.width > element.boundingBox.width) {
        return value;
      } else {
        return element;
      }
    });
    return face;
  }

  static const textFaceInside = 'Di chuyển khuôn mặt vào vùng nhận diện';
  static const textFaceOnFar = 'Vui lòng đưa điện thoại của bạn gần hơn';
  static const textFaceYFailure = 'Vui lòng nhìn thẳng';
  static const textFaceZFailure = 'Vui lòng giữ thẳng đầu';

  static double focusSize = 0.0;
  static double paddingLeft = 0.0;
  static double paddingRight = 0.0;
  static double paddingTop = 0.0;
  static double paddingBottom = 0.0;
  static Size screenSize = Size.zero;

  static updateScreenSize(Size size) {
    screenSize = size;
    focusSize = screenSize.width * FaceOption.focusViewRatio;
    paddingLeft = (screenSize.width - focusSize) / 2;
    paddingRight = paddingLeft + focusSize;
    paddingTop = (screenSize.height * focusTopPadding) / 2;
    paddingBottom = (3 * paddingTop) + focusSize;
  }

  static String getFaceMessage({
    required Face? face,
    required InputImage inputImage,
  }) {
    if (face == null) {
      return textFaceInside;
    }
    var imageData = inputImage.inputImageData!;
    var rotation = imageData.imageRotation;
    var size = imageData.size;
    final box = face.boundingBox;

    //because face on screen is flipped
    var faceLeft = translateX(box.right, rotation, screenSize, size);
    if (faceLeft < paddingLeft) {
      //dev.log('face_option failure left');
      return textFaceInside;
    }

    var faceRight = translateX(box.left, rotation, screenSize, size);
    if (faceRight > paddingRight) {
      //dev.log('face_option failure right');
      return textFaceInside;
    }

    var faceTop = translateY(box.top, rotation, screenSize, size);
    if (faceTop < paddingTop) {
      // dev.log('face_option failure top');
      return textFaceInside;
    }

    var faceBottom = translateY(box.bottom, rotation, screenSize, size);
    if (faceBottom > paddingBottom) {
      //dev.log('face_option failure bottom');
      return textFaceInside;
    }

    var validWidth = screenSize.width * FaceOption.faceWidthPercent;
    var faceWidth = (faceRight - faceLeft).abs();
    if (faceWidth < validWidth) {
      //dev.log('face_option failure width');
      //dev.log('face_option faceRight $faceRight');
      //dev.log('face_option faceLeft $faceLeft');
      //dev.log('face_option screenSize.width ${screenSize.width}');
      return textFaceOnFar;
    }

    var headEulerAngleY = face.headEulerAngleY ?? 0.0;
    if (headEulerAngleY < -8.0 || headEulerAngleY > 8.0) {
      //dev.log('face_option failure headEulerAngleY');
      return textFaceYFailure;
    }
    var headEulerAngleZ = face.headEulerAngleZ ?? 0.0;
    if (headEulerAngleZ < -8.0 || headEulerAngleZ > 8.0) {
      //dev.log('face_option failure headEulerAngleZ');
      return textFaceZFailure;
    }

    return '';
  }

  static Uint8List encodeImage(imgLib.Image image) {
    return Uint8List.fromList(FaceOption.jpegEncoder.encodeImage(image));
  }

  static imgLib.Image cropImage(Uint8List originImage) {
    imgLib.Image image = imgLib.decodeImage(originImage) as imgLib.Image;
    final cropWidth = image.width;
    final cropHeight = image.width * uploadHeight ~/ uploadWidth;
    final offsetY = (image.height * focusTopPadding).toInt();
    imgLib.Image newImage =
        imgLib.copyCrop(image, 0, offsetY, cropWidth, cropHeight);
    return newImage;
  }

  static imgLib.Image resizeImage(imgLib.Image originImage) {
    imgLib.Image thumbnail = imgLib.copyResize(
      originImage,
      width: uploadWidth,
      height: uploadHeight,
    );
    return thumbnail;
  }

  static log(Face face) {
    final box = face.boundingBox;
    var s = 'face: ';
    s += 'W ${box.width} ';
    s += 'H ${box.height} ';
    s += 'Center ${box.center.dx}-${box.center.dy} ';
    s += 'Left ${box.left} ';
    s += 'Right ${box.right} ';
    s += 'Top ${box.top} ';
    s += 'headEulerAngleY ${face.headEulerAngleY} ';
    s += 'headEulerAngleZ ${face.headEulerAngleZ} ';
    dev.log(s);
  }

  static final isIOS = Platform.isIOS;

  static double translateX(
    double x,
    InputImageRotation rotation,
    Size screenSize,
    Size imageSize,
  ) {
    switch (rotation) {
      case InputImageRotation.Rotation_90deg:
        var h = isIOS ? imageSize.width : imageSize.height;
        return x * screenSize.width / h;
      case InputImageRotation.Rotation_270deg:
        var h = isIOS ? imageSize.width : imageSize.height;
        return screenSize.width - x * screenSize.width / h;
      default:
        return x * screenSize.width / imageSize.width;
    }
  }

  static double translateY(
    double y,
    InputImageRotation rotation,
    Size size,
    Size imageSize,
  ) {
    switch (rotation) {
      case InputImageRotation.Rotation_90deg:
      case InputImageRotation.Rotation_270deg:
        var w = isIOS ? imageSize.height : imageSize.width;
        return y * size.height / w;
      default:
        return y * size.height / imageSize.height;
    }
  }
}
