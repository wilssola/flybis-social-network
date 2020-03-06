import "dart:io";

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";

import 'package:flybis/const.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/ViewPhoto.dart';

class ImageWidget extends StatefulWidget {
  final String url;
  final File file;
  final Color pageColor;
  final Function onDoubleTap;

  ImageWidget({this.url, this.file, this.pageColor, this.onDoubleTap});

  @override
  ImageWidgetState createState() => ImageWidgetState();
}

class ImageWidgetState extends State<ImageWidget> {
  void fullscreenImage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewPhoto(
          url: widget.url,
          pageColor: widget.pageColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: fullscreenImage,
      onDoubleTap: widget.onDoubleTap,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth:
              !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
          maxWidth:
              !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
          minHeight:
              !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
          maxHeight:
              !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
        ),
        child: FittedBox(
          fit: BoxFit.cover,
          child: cachedNetworkImage(widget.url),
        ),
      ),
    );
  }
}
