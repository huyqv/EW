import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FacePainter extends CustomPainter {
  FacePainter(this.face, this.imageSize, this.rotation);

  final Face face;
  final Size imageSize;
  final InputImageRotation rotation;

  static CustomPaint? customPaint({
    required Face? face,
    required InputImageData? imageData,
  }) {
    if (face == null || imageData == null) {
      return null;
    }
    return CustomPaint(
      painter: FacePainter(
        face,
        imageData.size,
        imageData.imageRotation,
      ),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = Colors.blueAccent;

    final box = face.boundingBox;
    canvas.drawRect(
      Rect.fromLTRB(
        translateX(box.left, rotation, size, imageSize),
        translateY(box.top, rotation, size, imageSize),
        translateX(box.right, rotation, size, imageSize),
        translateY(box.bottom, rotation, size, imageSize),
      ),
      paint,
    );

    //paintContour(canvas, size, paint);
  }

  void paintContour(Canvas canvas, Size size, Paint paint) {
    void paintContour(FaceContourType type) {
      final faceContour = face.getContour(type);
      if (faceContour?.positionsList != null) {
        for (Offset point in faceContour!.positionsList) {
          canvas.drawCircle(
            Offset(
              translateX(point.dx, rotation, size, imageSize),
              translateY(point.dy, rotation, size, imageSize),
            ),
            1,
            paint,
          );
        }
      }
    }

    paintContour(FaceContourType.face);
    paintContour(FaceContourType.leftEyebrowTop);
    paintContour(FaceContourType.leftEyebrowBottom);
    paintContour(FaceContourType.rightEyebrowTop);
    paintContour(FaceContourType.rightEyebrowBottom);
    paintContour(FaceContourType.leftEye);
    paintContour(FaceContourType.rightEye);
    paintContour(FaceContourType.upperLipTop);
    paintContour(FaceContourType.upperLipBottom);
    paintContour(FaceContourType.lowerLipTop);
    paintContour(FaceContourType.lowerLipBottom);
    paintContour(FaceContourType.noseBridge);
    paintContour(FaceContourType.noseBottom);
    paintContour(FaceContourType.leftCheek);
    paintContour(FaceContourType.rightCheek);
  }

  @override
  bool shouldRepaint(FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.face != face;
  }

  double translateX(double x, InputImageRotation rotation, Size size,
      Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.Rotation_90deg:
        return x *
            size.width /
            (Platform.isIOS
                ? absoluteImageSize.width
                : absoluteImageSize.height);
      case InputImageRotation.Rotation_270deg:
        return size.width -
            x *
                size.width /
                (Platform.isIOS
                    ? absoluteImageSize.width
                    : absoluteImageSize.height);
      default:
        return x * size.width / absoluteImageSize.width;
    }
  }

  double translateY(double y, InputImageRotation rotation, Size size,
      Size absoluteImageSize) {
    switch (rotation) {
      case InputImageRotation.Rotation_90deg:
      case InputImageRotation.Rotation_270deg:
        return y *
            size.height /
            (Platform.isIOS
                ? absoluteImageSize.height
                : absoluteImageSize.width);
      default:
        return y * size.height / absoluteImageSize.height;
    }
  }
}
