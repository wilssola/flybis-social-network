import "dart:io";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";

import "package:firebase_analytics/observer.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";

import "package:flutter_phoenix/flutter_phoenix.dart";

import "package:native_admob/native_admob.dart";
//import "package:native_flutter_admob/native_flutter_admob.dart";

import "package:flybis/pages/Home.dart";

main() {
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

    //Admob.initialize(getAdmobAppId());

    NativeAdmob().initialize(appID: "ca-app-pub-3940256099942544~3347511713");
  }

  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //FirebaseAnalytics analytics = FirebaseAnalytics();

    return MaterialApp(
      title: "Flybis",
      theme: ThemeData(
        primaryColor: Colors.black,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        // Button
        highlightColor: Colors.grey[50],
        hoverColor: Colors.grey[50],
        splashColor: Colors.grey[200],
      ),
      home: Home(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics(),
        ),
      ],
    );
  }
}

String getAdmobAppId() {
  if (Platform.isIOS) {
    return "ca-app-pub-3940256099942544~1458002511";
  } else if (Platform.isAndroid) {
    return "ca-app-pub-3940256099942544~3347511713";
  }
  return null;
}
