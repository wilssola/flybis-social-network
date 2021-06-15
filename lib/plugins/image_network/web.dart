// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:octo_image/octo_image.dart';
import 'package:transparent_image/transparent_image.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    required String imageUrl,
    var placeholder,
    var errorWidget,
    Alignment alignment: Alignment.center,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool showIconError = true,
    Color color = Colors.white,
    String blurHash: '',
  }) {
    if (imageUrl != null && imageUrl.length > 0) {
      return OctoImage(
        image: Image.network(imageUrl).image,
        placeholderBuilder: OctoPlaceholder.blurHash(
          blurHash,
        ),
        errorBuilder: OctoError.icon(color: Colors.red),
        alignment: alignment,
        fit: fit,
        width: width,
        height: height,
      );

      return FadeInImage.memoryNetwork(
        fit: fit,
        placeholder: kTransparentImage,
        image: imageUrl,
      );
    } else {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }
  }

  static ImageProvider cachedNetworkImageProvider(String url) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: url,
    ).image;
  }
}
