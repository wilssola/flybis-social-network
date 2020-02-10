import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    imageUrl,
    placeholder,
    errorWidget,
    alignment,
    fit,
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
