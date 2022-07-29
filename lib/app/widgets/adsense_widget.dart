// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_html/html.dart' as html;

// 🌎 Project imports:
import 'package:flybis/plugins/ui/ui.dart' as ui;

class AdsenseWidget extends StatelessWidget {
  const AdsenseWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) return const Padding(padding: EdgeInsets.zero);

    ui.platformViewRegistry.registerViewFactory(
      'adsenseType',
      (int viewId) => html.IFrameElement()
        ..width = '320'
        ..height = '100'
        ..src = 'adsense.html'
        ..style.border = 'none',
    );

    return const SizedBox(
      width: 320,
      height: 100,
      child: HtmlElementView(viewType: 'adsenseType'),
    );
  }
}
