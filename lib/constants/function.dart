// 🐦 Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:permission_handler/permission_handler.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/views/profile_view.dart';
import 'package:flybis/views/search_view.dart';

void setPortraitOrientations() {
  // Set Portrait Orientations
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  );
}

void setAllOrientations() {
  /// Set All Orientations.
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ],
  );
}

void setNotificationBar() {
  /// Show Notification Bar.
  SystemChrome.setEnabledSystemUIOverlays(
    [
      SystemUiOverlay.top,
      SystemUiOverlay.bottom,
    ],
  );

  /// Turn Notification Bar Transparent.
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
}

void onTapUsernameHashtagText(String text, Color pageColor) {
  logger.d('onTapUserHashText: ' + text);

  if (text.contains('@')) {
    openUsername(text, pageColor);
  } else {
    openQuery(text, pageColor);
  }
}

Future<void> handleCameraMicrophone() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();
}
