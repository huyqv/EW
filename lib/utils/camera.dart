import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';

InputImage getInputImage(
  CameraImage image,
  InputImageFormat format,
  InputImageRotation rotation,
) {
  final WriteBuffer allBytes = WriteBuffer();
  for (Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }

  final bytes = allBytes.done().buffer.asUint8List();

  final Size imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final planeData = image.planes.map(
    (Plane plane) {
      return InputImagePlaneMetadata(
        bytesPerRow: plane.bytesPerRow,
        height: plane.height,
        width: plane.width,
      );
    },
  ).toList();

  final inputImageData = InputImageData(
    size: imageSize,
    imageRotation: rotation,
    inputImageFormat: format,
    planeData: planeData,
  );

  return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
}

Uint8List? convertYUV420toBGRA8888(
  CameraImage cameraImage,
  InputImageRotation rotation,
) {
  try {
    final int width = cameraImage.width;
    final int height = cameraImage.height;
    final int uvRowStride = cameraImage.planes[1].bytesPerRow;
    final int uvPixelStride = cameraImage.planes[1].bytesPerPixel!;
    var image = imglib.Image(width, height); // Create Image buffer
    // Fill image buffer with plane[0] from YUV420_888
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        final int uvIndex =
            uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;
        final yp = cameraImage.planes[0].bytes[index];
        final up = cameraImage.planes[1].bytes[uvIndex];
        final vp = cameraImage.planes[2].bytes[uvIndex];
        // Calculate pixel color
        int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
        int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91)
            .round()
            .clamp(0, 255);
        int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
        // color: 0x FF  FF  FF  FF
        //           A   B   G   R
        image.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
      }
    }
    /*Image fixedImage;
    if (rotation == InputImageRotation.Rotation_270deg) {
      fixedImage = imglib.copyRotate(image, 90) as Image;
    } else if (rotation == InputImageRotation.Rotation_270deg) {
      fixedImage = imglib.copyRotate(image, 90) as Image;
    } else if (rotation == InputImageRotation.Rotation_270deg) {
      fixedImage = imglib.copyRotate(image, 90) as Image;
    } else {
      fixedImage = imglib.copyRotate(image, 90) as Image;
    }*/
    imglib.PngEncoder pngEncoder = imglib.PngEncoder(level: 0, filter: 0);
    List<int> png = pngEncoder.encodeImage(image);
    return Uint8List.fromList(png);
  } catch (e) {
    return null;
  }
}

Future<String> getImagePath() async {
  final Directory extDir = await getApplicationDocumentsDirectory();
  final String dirPath = '${extDir.path}/Pictures/fid';
  await Directory(dirPath).create(recursive: true);
  String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  return '$dirPath/$timestamp.jpg';
}

Future<String?> compressImageAndGetBase64(File file) async {
  var result = await FlutterImageCompress.compressWithFile(
    file.absolute.path,
    minWidth: 512,
    minHeight: 512,
    quality: 70,
  );
  if(result == null) return null;
  return base64Encode(result);
}

Future<File?> compressImageAndGetFile(File file, String targetPath) async {
  var result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    minWidth: 512,
    minHeight: 512,
    quality: 50,
  );
  return result;
}