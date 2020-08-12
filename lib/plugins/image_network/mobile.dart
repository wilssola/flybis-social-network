import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    String imageUrl,
    placeholder,
    errorWidget,
    Alignment alignment: Alignment.center,
    BoxFit fit,
    bool showIconError = true,
    Color color = Colors.white,
  }) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      placeholder: (context, url) =>
          Text(''), // Adicionar o BlurHash aqui futuramente.
      errorWidget: (context, url, error) => showIconError
          ? Icon(Icons.error)
          : Container(
              color: color,
              width: 1,
              height: 1,
            ),
      alignment: alignment,
      fit: fit,
    );
  }

  static ImageProvider cachedNetworkImageProvider(url) {
    return CachedNetworkImageProvider(url);
  }
}
