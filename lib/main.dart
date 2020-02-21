import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";

import "package:firebase_analytics/observer.dart";
import "package:firebase_admob/firebase_admob.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";

import "package:flutter_phoenix/flutter_phoenix.dart";

import "package:flybis/pages/Home.dart";
import 'package:flybis/const.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb) {
    // Set `enableInDevMode` to true to see reports while in debug mode
    // This is only to be used for confirming that reports are being
    // submitted as expected. It is not intended to be used for everyday
    // development.
    Crashlytics.instance.enableInDevMode = true;
    // Pass all uncaught errors from the framework to Crashlytics.
    FlutterError.onError = Crashlytics.instance.recordFlutterError;

    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    hideNavigationBar();

    FirebaseAdMob.instance.initialize(appId: getAdmobAppId());
  }

  runApp(
    Phoenix(
      child: App(),
    ),
  );
}

void hideNavigationBar() {
  SystemChrome.setEnabledSystemUIOverlays([]);
}

Widget home() {
  return Container(
    color: Colors.white,
    child: Padding(
      padding: EdgeInsets.only(bottom: 50),
      child: GestureDetector(
        onTap: hideNavigationBar,
        onDoubleTap: hideNavigationBar,
        child: Home(),
      ),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flybis",
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        highlightColor: Colors.grey[50],
        hoverColor: Colors.grey[50],
        splashColor: Colors.grey[200],
      ),
      home: home(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
