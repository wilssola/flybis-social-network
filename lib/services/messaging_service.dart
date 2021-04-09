// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/models/token_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class MessagingService {
  MessagingService();

  final DatabaseService _db = DatabaseService.instance;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final AwesomeNotifications _notifications = AwesomeNotifications();

  Future<void> initialize() async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      /// Update the iOS foreground notification presentation options to allow
      /// heads up notifications.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      await _notifications.initialize(
        'resource://drawable/flybis_icon_notification',
        [
          NotificationChannel(
            icon: 'resource://drawable/flybis_icon_notification',
            channelKey: 'miscellaneous',
            channelName: 'Miscellaneous Notifications',
            channelDescription:
                'This channel is used for miscellaneous notifications.',
            defaultColor: Colors.amber,
            ledColor: Colors.amber,
            vibrationPattern: lowVibrationPattern,
            onlyAlertOnce: true,
          ),
          NotificationChannel(
            icon: 'resource://drawable/flybis_icon_notification',
            channelKey: 'high_importance_channel',
            channelName: 'High Importance Notifications',
            channelDescription:
                'This channel is used for high importance notifications.',
            defaultColor: Colors.amber,
            ledColor: Colors.amber,
            vibrationPattern: highVibrationPattern,
            onlyAlertOnce: true,
            importance: NotificationImportance.High,
            enableVibration: true,
            playSound: true,
          ),
          NotificationChannel(
            icon: 'resource://drawable/flybis_icon_notification',
            channelKey: 'progress_bar_channel',
            channelName: 'Progress Bar Notifications',
            channelDescription:
                'This channel is used for progress bar notifications.',
            defaultColor: Colors.amber,
            ledColor: Colors.amber,
            vibrationPattern: lowVibrationPattern,
            onlyAlertOnce: true,
          ),
        ],
      );

      _notifications.isNotificationAllowed().then((isAllowed) {
        if (!isAllowed) {
          // Insert here your friendly dialog box before call the request method.
          // This is very important to not harm the user experience.
          _notifications.requestPermissionToSendNotifications();
        }
      });
    }
  }

  Future<RemoteMessage> getInitialMessage() async {
    return await _messaging.getInitialMessage();
  }

  Future<void> showHighNotification(RemoteNotification notification) async {
    try {
      await _notifications.createNotification(
        content: NotificationContent(
          id: notification.hashCode,
          title: notification.title,
          body: notification.body,
          notificationLayout: NotificationLayout.Default,
        ),
      );
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> showProgressNotification(
    int progress,
    int endProgress, {
    int id = 0,
    String progressMessage = 'Progress',
    String endMessage = 'Progress End',
  }) async {
    try {
      await Future.delayed(Duration(milliseconds: 100), () async {
        if (progress >= endProgress) {
          await _notifications.createNotification(
            content: NotificationContent(
              id: id,
              channelKey: 'progress_bar',
              title: endMessage,
              body: '',
              payload: {'file': '', 'path': '-rmdir C://flybis'},
              locked: false,
            ),
          );
        } else {
          await _notifications.createNotification(
            content: NotificationContent(
              id: id,
              channelKey: 'progress_bar',
              title: '$progressMessage ($progress of $endProgress)',
              body: '',
              payload: {'file': '', 'path': '-rmdir C://flybis'},
              notificationLayout: NotificationLayout.ProgressBar,
              progress: min((progress / endProgress * 100).round(), 100),
              locked: true,
            ),
          );
        }
      });
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> configureMessaging(String userId) async {
    await _messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    _messaging.getToken().then((String token) async {
      await configureToken(userId, token);

      print('getToken: (token=$token)');
    });

    _messaging.onTokenRefresh.listen((String token) async {
      await configureToken(userId, token);

      print('onTokenRefresh: (token=$token)');
    });
  }

  Future<void> configureToken(String userId, String token) async {
    const String tokenId = 'fcm';

    FlybisTokenMessaging flybisTokenMessaging = await _db.get(
      documentPath: PathService.userToken(userId, tokenId),
      builder: (data, documentId) =>
          FlybisTokenMessaging.fromMap(data, documentId),
    );

    if (flybisTokenMessaging == null) {
      flybisTokenMessaging = FlybisTokenMessaging();

      if (Platform.isAndroid) {
        flybisTokenMessaging.androidToken = token;
      } else if (Platform.isIOS) {
        flybisTokenMessaging.iosToken = token;
      }

      await _db.set(
        documentPath: PathService.userToken(userId, tokenId),
        data: flybisTokenMessaging.toMap(),
      );
    } else {
      if (Platform.isAndroid) {
        flybisTokenMessaging.androidToken = token;
      } else if (Platform.isIOS) {
        flybisTokenMessaging.iosToken = token;
      }

      await _db.update(
        documentPath: PathService.userToken(userId, tokenId),
        data: flybisTokenMessaging.toMap(),
      );
    }
  }
}
