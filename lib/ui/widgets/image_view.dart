import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sample/ui/res/image_name.dart';

class ImageView extends StatefulWidget {
  final String? image;
  final double? width;
  final double? height;

  const ImageView({Key? key, required this.image, this.width, this.height})
      : super(key: key);

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      width: widget.width,
      height: widget.height,
      imageUrl: widget.image ?? "",
      fit: BoxFit.cover,
      placeholder: (context, url) => Image.asset(
        ImageName.avatar,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      ),
      errorWidget: (context, url, error) => Image.asset(
        ImageName.avatar,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      ),
    );
  }
}

class CircleImageView extends StatefulWidget {
  final String? imageUrl;
  final double width;
  final double height;

  const CircleImageView(
      {Key? key, this.imageUrl, required this.width, required this.height})
      : super(key: key);

  @override
  _CircleImageViewState createState() => _CircleImageViewState();
}

class _CircleImageViewState extends State<CircleImageView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(1000)),
          child: Image.network(
            widget.imageUrl!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, obj, stackTrace) => Image.asset(
              ImageName.avatar,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
            loadingBuilder: (context, child, event) => Image.asset(
              ImageName.avatar,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
          )),
    );
  }
}
