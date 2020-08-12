import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";

import "package:firebase_analytics/observer.dart";
import "package:firebase_analytics/firebase_analytics.dart";
import "package:firebase_crashlytics/firebase_crashlytics.dart";

import "package:flutter_phoenix/flutter_phoenix.dart";

import "package:flybis/pages/App.dart";

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /*
  if (!kReleaseMode) {
    print('Using local emulator firebase as backend...');

    await Firestore.instance.settings(
      host: '192.168.0.45:8000',
      sslEnabled: false,
      persistenceEnabled: false,
    );

    CloudFunctions.instance.useFunctionsEmulator(
      origin: 'http://192.168.0.45:6000',
    );
  }
  */

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
      ],
    );
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
  }

  runApp(
    Phoenix(child: Main()),
  );
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flybis",
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: Colors.black,
        splashColor: Colors.white,
        accentColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.white,
        splashColor: Colors.black,
        accentColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: App(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(
          analytics: FirebaseAnalytics(),
        ),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
