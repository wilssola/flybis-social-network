// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_html/html.dart' as html;

extension MouseHover on Widget {
  // Get a regerence to the body of the view
  static final html.Element? app = html.window.document.getElementById('app');

  Widget get showCursorOnHover {
    return MouseRegion(
      child: this,
      // When the mouse enters the widget set the cursor to pointer
      onHover: (event) {
        app!.style.cursor = 'pointer';
      },
      // When it exits set it back to default
      onExit: (event) {
        app!.style.cursor = 'default';
      },
    );
  }
}
