import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    throw 'Platform Not Supported';
  }

  static ImageProvider cachedNetworkImageProvider(url) {
    throw 'Platform Not Supported';
  }
}
