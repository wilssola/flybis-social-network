// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/models/flybis_model.dart';
import 'package:flybis/extensions/NoTransitionsOnWeb.dart';

// Themes
final ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  iconTheme: const IconThemeData(color: Colors.black),
  applyElevationOverlayColor: false,
  pageTransitionsTheme: NoTransitionsOnWeb(),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.black,
    selectionColor: Colors.blue[800],
  ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  iconTheme: const IconThemeData(color: Colors.white),
  applyElevationOverlayColor: true,
  pageTransitionsTheme: NoTransitionsOnWeb(),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: Colors.white,
    selectionColor: Colors.blue[800],
  ), colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.white),
);

// Pages
final List<Color> pageColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.cyan,
  Colors.pink,
  Colors.amber, //Colors.yellow[700]
];

final List<FlybisView> pages = [
  FlybisView.set(
    Icons.home,
    'timeline'.tr,
    pageColors[0],
  ),
  FlybisView(
    iconData: Icons.notifications,
    icon: const Icon(Icons.notifications),
    string: 'bell'.tr,
    text: Text('bell'.tr),
    color: pageColors[1],
  ),
  FlybisView(
    iconData: Icons.camera,
    icon: const Icon(Icons.camera),
    string: 'camera'.tr,
    text: Text('camera'.tr),
    color: pageColors[2],
  ),
  FlybisView(
    iconData: Icons.account_circle,
    icon: const Icon(Icons.account_circle),
    string: 'profile'.tr,
    text: Text('profile'.tr),
    color: pageColors[3],
  ),
  FlybisView(
    iconData: Icons.mail,
    icon: const Icon(Icons.mail),
    string: 'chat'.tr,
    text: Text('chat'.tr),
    color: pageColors[4],
  ),
  FlybisView(
    iconData: Icons.search,
    icon: const Icon(Icons.search),
    string: 'search'.tr,
    text: Text('search'.tr),
    color: pageColors[5],
  ),
];
