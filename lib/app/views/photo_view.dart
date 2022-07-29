// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:photo_view/photo_view.dart' as photo_view;

import 'package:flybis/plugins/image_network/image_network.dart'
    deferred as image_network;

Future<bool> loadLibraries() async {
  image_network.loadLibrary();

  return true;
}

class PhotoView extends StatefulWidget {
  final String title;
  final String? url;
  final Color? pageColor;

  const PhotoView({
    this.title = 'Imagem',
    required this.url,
    this.pageColor,
  });

  @override
  _PhotoViewState createState() => _PhotoViewState();
}

class _PhotoViewState extends State<PhotoView> {
  _PhotoViewState();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            centerTitle: false,
            backgroundColor: widget.pageColor ?? Theme.of(context).primaryColor,
          ),
          body: Container(
            child: photo_view.PhotoView(
              imageProvider:
                  image_network.ImageNetwork.cachedNetworkImageProvider(
                widget.url!,
              ),
            ),
          ),
        );
      },
    );
  }
}
