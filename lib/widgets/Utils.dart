import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../plugins/image_network/image_network.dart';
import '../const.dart';

import './Progress.dart';

Widget logoText(pageColors) {
  if (!kIsWeb) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontFamily: "Matiz", fontSize: 75.0),
        children: <TextSpan>[
          TextSpan(text: "F", style: TextStyle(color: pageColors[0])),
          TextSpan(text: "L", style: TextStyle(color: pageColors[1])),
          TextSpan(text: "Y", style: TextStyle(color: pageColors[2])),
          TextSpan(text: "B", style: TextStyle(color: pageColors[3])),
          TextSpan(text: "I", style: TextStyle(color: pageColors[4])),
          TextSpan(text: "S", style: TextStyle(color: pageColors[5])),
        ],
      ),
    );
  } else {
    return Text(
      "FLYBIS",
      style: TextStyle(
        fontFamily: "Matiz",
        fontSize: 75.0,
        color: pageColors[Random().nextInt(pageColors.length)],
      ),
    );
  }
}

Widget cachedNetworkImage(String contentUrl) {
  return ImageNetwork.cachedNetworkImage(
    imageUrl: contentUrl != null ? contentUrl : "",
    fit: BoxFit.cover,
    placeholder: (context, url) => Padding(
      child: circularProgress(),
      padding: EdgeInsets.all(17.5),
    ),
    errorWidget: (context, url, error) => Icon(Icons.error),
  );
}

Widget adaptiveImage(context, url) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      maxWidth: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      minHeight:
          !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      maxHeight:
          !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
    ),
    child: FittedBox(fit: BoxFit.cover, child: cachedNetworkImage(url)),
  );
}

Widget adaptiveVideo(context, controller) {
  return ClipRect(
    child: Container(
      child: Transform.scale(
        scale: (controller.value.aspectRatio) /
            (MediaQuery.of(context).size.aspectRatio * 1.2),
        child: Center(
          child: AspectRatio(
            aspectRatio: MediaQuery.of(context).size.width /
                (MediaQuery.of(context).size.width * 0.825),
            child: VideoPlayer(controller),
          ),
        ),
      ),
    ),
  );
}

Widget infoText(String text) {
  return Center(child: Text(text, style: TextStyle(fontSize: 20)));
}

Widget listViewContainer(BuildContext context, Widget child) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.8,
    child: child,
  );
}

// Username
Text usernameText(String username) {
  return Text("@" + username, style: usernameStyle());
}

TextStyle usernameStyle() {
  return TextStyle(color: Colors.blue, fontWeight: FontWeight.bold);
}
// Username - End

// Snackbar
showSnackbar(GlobalKey<ScaffoldState> scaffoldKey, String content,
    {int duration = 4}) {
  final SnackBar snackbar = SnackBar(
    content: Text(content),
    duration: Duration(seconds: duration),
  );

  scaffoldKey.currentState.showSnackBar(snackbar);
}

hideSnackbar(GlobalKey<ScaffoldState> scaffoldKey) {
  scaffoldKey.currentState.hideCurrentSnackBar();
}

removeSnackbar(GlobalKey<ScaffoldState> scaffoldKey) {
  scaffoldKey.currentState.removeCurrentSnackBar();
}
// Snackbar - End
