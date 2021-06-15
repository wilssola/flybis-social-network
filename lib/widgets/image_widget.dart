// 🐦 Flutter imports:
import "package:flutter/material.dart";

// 📦 Package imports:
import 'package:animations/animations.dart';

// 🌎 Project imports:
import 'package:flybis/views/photo_view.dart' deferred as photo_view;
import 'package:flybis/widgets/utils_widget.dart' deferred as utils_widget;

Future<bool> loadLibraries() async {
  await photo_view.loadLibrary();
  await utils_widget.loadLibrary();

  return true;
}

class ImageWidget extends StatefulWidget {
  final String? url;
  final String? blurHash;
  final Color? pageColor;
  final Function? onDoubleTap;

  ImageWidget({
    required this.url,
    required this.blurHash,
    this.pageColor,
    this.onDoubleTap,
    required Key key,
  }) : super(key: key);

  @override
  ImageWidgetState createState() => ImageWidgetState();
}

class ImageWidgetState extends State<ImageWidget> {
  void fullscreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => photo_view.PhotoView(
          url: widget.url,
          pageColor: widget.pageColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (
        BuildContext context,
        AsyncSnapshot<void> snapshot,
      ) {
        if (!snapshot.hasData) {
          return Text('');
        }

        return OpenContainer(
          closedBuilder: (BuildContext context, Function() action) {
            return utils_widget.UtilsWidget().adaptiveImage(
              context,
              widget.url,
              widget.blurHash!,
            );
          },
          openBuilder: (BuildContext context, Function() action) {
            return photo_view.PhotoView(
              url: widget.url,
              pageColor: widget.pageColor,
            );
          },
        );

        return GestureDetector(
          onTap: () => fullscreen(context),
          onDoubleTap: () => widget.onDoubleTap,
          child: utils_widget.UtilsWidget().adaptiveImage(
            context,
            widget.url,
            widget.blurHash!,
          ),
        );
      },
    );
  }
}
