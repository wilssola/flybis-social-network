// 🎯 Dart imports:
import 'dart:async';
import 'dart:ui' deferred as ui;

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart' deferred as foundation;
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:firebase_core/firebase_core.dart' deferred as firebase_core;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:universal_io/io.dart' deferred as io;
import 'package:url_strategy/url_strategy.dart';
import 'package:responsive_framework/responsive_framework.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/function.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/routes/routes.dart';
import 'package:flybis/app/data/providers/messaging_provider.dart';
import 'package:flybis/translation.dart' deferred as translation;

// 📦 Package imports:
import 'package:firebase_analytics/firebase_analytics.dart'
    deferred as firebase_analytics;
import 'package:firebase_analytics/observer.dart'
    deferred as firebase_analytics_observer;
import 'package:firebase_app_check/firebase_app_check.dart'
    deferred as firebase_app_check;
import 'package:firebase_crashlytics/firebase_crashlytics.dart'
    deferred as firebase_crashlytics;
import 'package:firebase_messaging/firebase_messaging.dart'
    deferred as firebase_messaging;
import 'package:flutter_phoenix/flutter_phoenix.dart'
    deferred as flutter_phoenix;
import 'package:flybis/extensions/NoGlowOnListView.dart'
    deferred as no_glow_on_list_view;

Future<bool> loadLibraries() async {
  // Dart
  await ui.loadLibrary();

  await foundation.loadLibrary();

  await translation.loadLibrary();
  await no_glow_on_list_view.loadLibrary();
  //await app.loadLibrary();

  await firebase_core.loadLibrary();
  await firebase_messaging.loadLibrary();
  await firebase_analytics.loadLibrary();
  await firebase_analytics_observer.loadLibrary();
  await firebase_crashlytics.loadLibrary();
  await firebase_app_check.loadLibrary();

  await flutter_phoenix.loadLibrary();

  await io.loadLibrary();

  return true;
}

Future<void> initFirebase() async {
  await firebase_core.Firebase.initializeApp();

  // Activate app check after initialization, but before
  // usage of any Firebase services.
  await firebase_app_check.FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: '6LcGDlIbAAAAAK-Byn66igAealfB020j8YSbNVJ9',
  );
}

void initMessaging() {
  firebase_messaging.FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
}

Future<void> onBackgroundMessage(var message) async {
  try {
    await firebase_core.Firebase.initializeApp();
    logger.i('onBackgroundMessage: ${message.messageId}');

    if (message.notification == null) return;

    MessagingProvider.instance.showHighNotification(message.notification);
    logger.i('showHighNotification: ${message.notification}');
  } catch (error) {
    logger.e(error);
  }
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

Future<InitializationStatus> initGoogleMobileAds() {
  // Initialize Google Mobile Ads SDK
  return MobileAds.instance.initialize();
}

Future<void> initSentry(Function runApp) async {
  try {
    await SentryFlutter.init(
      (SentryFlutterOptions options) {
        options.dsn =
            'https://66b767fd4d654fb19e2dde01a47bd8b3@o541444.ingest.sentry.io/5660368';
      },
      appRunner: runApp(),
    );
  } catch (error) {
    runApp();
    
    logger.e(error);
  }
}

void main() async {
  await loadLibraries();

  WidgetsFlutterBinding.ensureInitialized();

  if (!io.Platform.isWindows && !io.Platform.isLinux) {
    await initFirebase();
    initMessaging();

    if (!foundation.kIsWeb) {
      initCrashlytics();
      await initGoogleMobileAds();

      setAllOrientations();
      setNotificationBar();
    }

    MessagingProvider.instance.initialize();
  }

  /// Here we set the URL strategy for our web app.
  /// It is safe to call this function when running on mobile or desktop as well.
  setPathUrlStrategy();

  await initSentry(
    () => runZonedGuarded(
      () => runApp(flutter_phoenix.Phoenix(child: const Main())),
      firebase_crashlytics.FirebaseCrashlytics.instance.recordError,
    ),
  );
}

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MainState();
}

class _MainState extends State<Main> {
  @override
  void initState() {
    super.initState();

    if (io.Platform.isWindows || io.Platform.isLinux) return;

    MessagingProvider.instance.getInitialMessage().then((var message) {
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

            MessagingProvider.instance.showHighNotification(notification);
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
      //theme: theme,
      //darkTheme: darkTheme,
      //themeMode: ThemeMode.light,
      //home: app.App(),
      builder: (BuildContext context, Widget? child) {
        return ResponsiveWrapper.builder(
          ScrollConfiguration(
            behavior: no_glow_on_list_view.NoGlowOnListView(),
            child: child!,
          ),
          defaultScale: true,
          maxWidth: 1200,
          minWidth: 480,
          breakpoints: [
            ResponsiveBreakpoint.resize(480, name: MOBILE),
            ResponsiveBreakpoint.autoScale(800, name: TABLET),
            ResponsiveBreakpoint.resize(1000, name: DESKTOP),
          ],
          background: Container(
            color: Color(0xFFF5F5F5),
          ),
        );
      },
      initialRoute: initialRoute,
      routes: routes,
      navigatorObservers: [
        firebase_analytics_observer.FirebaseAnalyticsObserver(
          analytics: firebase_analytics.FirebaseAnalytics.instance,
        ),
      ],
      locale: ui.window.locale,
      fallbackLocale: translation.Translation.fallbackLocale,
      translations: translation.Translation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
