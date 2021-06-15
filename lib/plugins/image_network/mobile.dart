// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:octo_image/octo_image.dart';

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
        image: CachedNetworkImageProvider(imageUrl),
        placeholderBuilder: OctoPlaceholder.blurHash(
          blurHash,
        ),
        errorBuilder: OctoError.icon(color: Colors.red),
        alignment: alignment,
        fit: fit,
        width: width,
        height: height,
      );

      return CachedNetworkImage(
        imageUrl: imageUrl,
        placeholder: (context, url) =>
            Text(''), // Adicionar o BlurHash aqui futuramente.
        errorWidget: (context, url, error) => showIconError
            ? Icon(Icons.error)
            : Container(
                color: color,
                width: width,
                height: height,
              ),
        alignment: alignment,
        fit: fit,
        width: width,
        height: height,
      );
    } else {
      return Padding(
        padding: EdgeInsets.zero,
      );
    }
  }

  static ImageProvider cachedNetworkImageProvider(String url) {
    return CachedNetworkImageProvider(url);
  }
}
