// 🐦 Flutter imports:
import 'package:flutter/material.dart';

class NoGlowOnListView extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
    BuildContext context,
    Widget child,
    AxisDirection axisDirection,
  ) {
    return child;
  }
}
