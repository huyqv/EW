

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class MediaSizeClipper extends CustomClipper<Rect> {
  final Size mediaSize;

  const MediaSizeClipper(this.mediaSize);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, mediaSize.width, mediaSize.height);
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) {
    return true;
  }
}

Widget fullscreenCamera(BuildContext context, CameraController controller){
  final screenWidth = MediaQuery.of(context).size;
  final scale = 1 / (controller.value.aspectRatio * screenWidth.aspectRatio);
  return ClipRect(
    clipper: MediaSizeClipper(screenWidth),
    child: Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: CameraPreview(controller),
    ),
  );
}

Widget fullscreenContainer(BuildContext context, SizedBox child){
  final screenWidth = MediaQuery.of(context).size;
  final scale = 1 / (child.width!.toDouble() / child.height!.toDouble() * screenWidth.aspectRatio);
  return ClipRect(
    clipper: MediaSizeClipper(screenWidth),
    child: Transform.scale(
      scale: scale,
      alignment: Alignment.topCenter,
      child: child,
    ),
  );
}