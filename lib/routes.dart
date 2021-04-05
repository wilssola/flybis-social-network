// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:flybis/app.dart';

final Map<String, int> urls = {
  '/': 0,
  '/timeline': 0,
  '/bells': 1,
  '/camera': 2,
  '/profile': 3,
  '/chat': 4,
  '/search': 5,
};

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => App(page: 0),
  '/timeline': (context) => App(page: 0),
  '/bells': (context) => App(page: 1),
  '/camera': (context) => App(page: 2),
  '/profile': (context) => App(page: 3),
  '/chat': (context) => App(page: 4),
  '/search': (context) => App(page: 5),
};

final String initialRoute = routes.entries.first.key;
