import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final Color avatarBackground = Colors.grey[200];

final Color buttonColor = Colors.grey[100];

TextStyle usernameStyle() {
  return TextStyle(
    color: Colors.blue,
    fontWeight: FontWeight.bold,
  );
}

String getAdmobAppId() {
  if (Platform.isAndroid) {
    return "ca-app-pub-4246318576696519~5080060739";
  } else if (Platform.isIOS) {
    return "";
  }
  return null;
}

String getBannerAdUnitId() {
  if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  } else if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  }
  return null;
}
