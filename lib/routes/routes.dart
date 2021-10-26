// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:flybis/app/app.dart';

final Map<String, int> pages = {
  '/': 0,
  '/timeline': 0,
  '/notification': 1,
  '/camera': 2,
  '/profile': 3,
  '/chat': 4,
  '/search': 5,
};

final Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => App(pageIndex: pages['/']!),
  '/timeline': (context) => App(pageIndex: pages['/timeline']!),
  '/notification': (context) => App(pageIndex: pages['/notification']!),
  '/camera': (context) => App(pageIndex: pages['/camera']!),
  '/profile/:username': (context) => App(pageIndex: pages['/profile']!),
  '/chat/:chat': (context) => App(pageIndex: pages['/chat']!),
  '/search/:query': (context) => App(pageIndex: pages['/search']!),
};

final String initialRoute = routes.entries.first.key;
