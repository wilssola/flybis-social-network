// 🎯 Dart imports:
import './unsupported.dart' if (dart.library.html) 'dart:ui' as ui;

// ignore: camel_case_types
class platformViewRegistry {
  static registerViewFactory(String viewId, dynamic cb) {
    ui.platformViewRegistry.registerViewFactory(viewId, cb);
  }
}
