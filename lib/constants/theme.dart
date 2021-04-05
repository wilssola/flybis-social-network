// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/extensions/NoTransitionsOnWeb.dart';
import 'package:flybis/models/page_model.dart';

// Themes
final ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.black,
  accentColor: Colors.black,
  cursorColor: Colors.black,
  textSelectionColor: Colors.blue[800],
  iconTheme: IconThemeData(color: Colors.black),
  applyElevationOverlayColor: false,
  pageTransitionsTheme: NoTransitionsOnWeb(),
);

final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.white,
  accentColor: Colors.white,
  cursorColor: Colors.white,
  textSelectionColor: Colors.blue[800],
  iconTheme: IconThemeData(color: Colors.white),
  applyElevationOverlayColor: true,
  pageTransitionsTheme: NoTransitionsOnWeb(),
);

// Pages
final List<Color> pageColors = [
  pages[0].color,
  pages[1].color,
  pages[2].color,
  pages[3].color,
  pages[4].color,
  pages[5].color,
];

final List<PageModel> pages = [
  PageModel(
    iconData: Icons.home,
    icon: Icon(Icons.home),
    string: 'timeline'.tr,
    text: Text('timeline'.tr),
    color: Colors.red,
  ),
  PageModel(
    iconData: Icons.notifications,
    icon: Icon(Icons.notifications),
    string: 'bell'.tr,
    text: Text('bell'.tr),
    color: Colors.green,
  ),
  PageModel(
    iconData: Icons.camera,
    icon: Icon(Icons.camera),
    string: 'camera'.tr,
    text: Text('camera'.tr),
    color: Colors.blue,
  ),
  PageModel(
    iconData: Icons.account_circle,
    icon: Icon(Icons.account_circle),
    string: 'profile'.tr,
    text: Text('profile'.tr),
    color: Colors.cyan,
  ),
  PageModel(
    iconData: Icons.mail,
    icon: Icon(Icons.mail),
    string: 'chat'.tr,
    text: Text('chat'.tr),
    color: Colors.pink,
  ),
  PageModel(
    iconData: Icons.search,
    icon: Icon(Icons.search),
    string: 'search'.tr,
    text: Text('search'.tr),
    color: Colors.yellow[700],
  ),
];
