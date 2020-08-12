import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    String imageUrl,
    placeholder,
    errorWidget,
    Alignment alignment,
    BoxFit fit,
    bool showIconError,
    Color color,
  }) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: imageUrl,
    );
  }

  static ImageProvider cachedNetworkImageProvider(url) {
    return FadeInImage.memoryNetwork(
      placeholder: kTransparentImage,
      image: url,
    ).image;
  }
}
