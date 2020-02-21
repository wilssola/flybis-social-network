import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    imageUrl,
    placeholder,
    errorWidget,
    alignment: Alignment.center,
    fit,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      alignment: alignment,
      fit: fit,
    );
  }

  static ImageProvider cachedNetworkImageProvider(url) {
    return CachedNetworkImageProvider(url);
  }
}
