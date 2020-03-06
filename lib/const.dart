import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

final Color avatarBackground = Colors.grey[200];

final Color buttonColor = Colors.grey[100];

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
    return '';
  }
  return null;
}

widthWeb(context) {
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
  } else {
    return MediaQuery.of(context).size.width;
  }
}
