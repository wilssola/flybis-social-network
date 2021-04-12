// 🎯 Dart imports:
import 'dart:ui' deferred as ui;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' deferred as foundation;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:firebase_analytics/observer.dart' deferred as observer;
import 'package:firebase_core/firebase_core.dart' deferred as firebase_core;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_strategy/url_strategy.dart';

// 🌎 Project imports:
import 'package:flybis/constants/function.dart';
import 'package:flybis/constants/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/routes.dart';
import 'package:flybis/services/messaging_service.dart';
import 'package:flybis/translation.dart' deferred as translation;

import 'package:flybis/extensions/NoGlowOnListView.dart'
    deferred as no_glow_on_list_view;

import 'package:firebase_messaging/firebase_messaging.dart'
    deferred as firebase_messaging;
import 'package:firebase_analytics/firebase_analytics.dart'
    deferred as firebase_analytics;
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    deferred as firebase_crashlytics;

import 'package:flutter_phoenix/flutter_phoenix.dart'
    deferred as flutter_phoenix;

Future<bool> loadLibraries() async {
  // Dart
  await ui.loadLibrary();

  await foundation.loadLibrary();

  await translation.loadLibrary();
  await no_glow_on_list_view.loadLibrary();
  //await app.loadLibrary();

  await firebase_core.loadLibrary();
  await firebase_messaging.loadLibrary();
  await observer.loadLibrary();
  await firebase_analytics.loadLibrary();
  await firebase_crashlytics.loadLibrary();

  await flutter_phoenix.loadLibrary();

  return true;
}

Future<void> initFirebase() async {
  await firebase_core.Firebase.initializeApp();
}

void initMessaging() {
  firebase_messaging.FirebaseMessaging.onBackgroundMessage((var message) async {
    try {
      await firebase_core.Firebase.initializeApp();

      logger.i("Handling a background message: ${message.messageId}");

      var notification = message.notification;
      var android = message.notification?.android;

      if (notification != null && android != null) {
        logger.i('onBackgroundMessage: $notification');

        MessagingService().showHighNotification(notification);
      }
    } catch (error) {
      logger.e(error);
    }
  });
}

void initCrashlytics() {
  /// Set `enableInDevMode` to true to see reports while in debug mode
  /// This is only to be used for confirming that reports are being
  /// submitted as expected. It is not intended to be used for everyday
  /// development.
  firebase_crashlytics.FirebaseCrashlytics.instance
      .setCrashlyticsCollectionEnabled(true);

  /// Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError =
      firebase_crashlytics.FirebaseCrashlytics.instance.recordFlutterError;
}

Future<void> initSentry(Function runApp) async {
  try {
    await SentryFlutter.init(
      (SentryFlutterOptions options) => options.dsn =
          'https://66b767fd4d654fb19e2dde01a47bd8b3@o541444.ingest.sentry.io/5660368',
      appRunner: runApp,
    );
  } catch (error) {
    logger.e(error);
    runApp();
  }
}

Future<InitializationStatus> initGoogleMobileAds() {
  // Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}

void main() async {
  await loadLibraries();

  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();
  initMessaging();

  if (!foundation.kIsWeb) {
    initCrashlytics();
    await initGoogleMobileAds();

    setAllOrientations();
    setNotificationBar();
  }

  /// Here we set the URL strategy for our web app.
  /// It is safe to call this function when running on mobile or desktop as well.
  setPathUrlStrategy();

  MessagingService().initialize();

  await initSentry(() => runApp(flutter_phoenix.Phoenix(child: Main())));
}

class Main extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();

    MessagingService().getInitialMessage().then((var message) {
      if (message != null) {
        logger.i('getInitialMessage: $message');
      }
    });

    firebase_messaging.FirebaseMessaging.onMessage.listen(
      (var message) {
        try {
          var notification = message.notification;
          var android = message.notification?.android;

          if (notification != null && android != null) {
            logger.i('onMessage: $notification');

            MessagingService().showHighNotification(notification);
          }
        } catch (error) {
          logger.e(error);
        }
      },
    );

    firebase_messaging.FirebaseMessaging.onMessageOpenedApp.listen(
      (var message) {
        logger.i('onMessageOpenedApp: $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flybis',
      theme: theme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      //home: app.App(),
      builder: (BuildContext context, Widget child) {
        return ScrollConfiguration(
          behavior: no_glow_on_list_view.NoGlowOnListView(),
          child: child,
        );
      },
      initialRoute: initialRoute,
      routes: routes,
      navigatorObservers: [
        observer.FirebaseAnalyticsObserver(
          analytics: firebase_analytics.FirebaseAnalytics(),
        ),
      ],
      locale: ui.window.locale,
      fallbackLocale: translation.Translation.fallbackLocale,
      translations: translation.Translation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
