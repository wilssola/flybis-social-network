// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class ImageNetwork {
  ImageNetwork._();

  static Widget cachedNetworkImage({
    required String imageUrl,
    var placeholder,
    var errorWidget,
    Alignment alignment = Alignment.center,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    bool showIconError = true,
    Color color = Colors.white,
    String blurHash = '',
  }) {
    throw 'Platform Not Supported';
  }

  static ImageProvider cachedNetworkImageProvider(String url) {
    throw 'Platform Not Supported';
  }
}
