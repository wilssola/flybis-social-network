// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Admob
//import 'package:admob_consent/admob_consent.dart';

// Functions
final FirebaseFunctions functions = FirebaseFunctions.instance;

// Auth
final FirebaseAuth auth = FirebaseAuth.instance;

// Storage
final Reference storage = FirebaseStorage.instance.ref();
Reference storageUrlRef(url) => FirebaseStorage.instance.refFromURL(url);

// Realtime
//final DatabaseReference realtime = FirebaseDatabase.instance.reference();

// Messaging
//final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

// Admob
//final AdmobConsent admobConsent = AdmobConsent();

final Color? buttonColor = Colors.grey[100];
final Color? kAvatarBackground = Colors.grey[200];

final int kAppBottomBarHeight = 60;

final double kWebDrawerWidth = 300;
double kWebBodyWidth(BuildContext context) =>
    MediaQuery.of(context).size.width - kWebDrawerWidth;

bool kScreenLittle(BuildContext context) =>
    MediaQuery.of(context).size.width <= 720;

bool kNotIsWebOrScreenLittle(BuildContext context) =>
    !kIsWeb || kScreenLittle(context);

double widthWeb(BuildContext context) {
  if (MediaQuery.of(context).size.width > 1600) {
    return MediaQuery.of(context).size.width * 0.3;
  } else if (MediaQuery.of(context).size.width > 1440) {
    return MediaQuery.of(context).size.width * 0.35;
  } else if (MediaQuery.of(context).size.width > 1366) {
    return MediaQuery.of(context).size.width * 0.4;
  } else if (MediaQuery.of(context).size.width > 1280) {
    return MediaQuery.of(context).size.width * 0.45;
  } else if (MediaQuery.of(context).size.width > 1024) {
    return MediaQuery.of(context).size.width * 0.5;
  } else if (MediaQuery.of(context).size.width > 720) {
    return MediaQuery.of(context).size.width * 0.55;
  } else {
    return MediaQuery.of(context).size.width;
  }
}
