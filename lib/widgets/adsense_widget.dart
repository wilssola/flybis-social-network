// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_html/html.dart' as html;

// 🌎 Project imports:
import 'package:flybis/plugins/ui/ui.dart' as ui;

class AdsenseWidget extends StatelessWidget {
  AdsenseWidget();

  Widget build(BuildContext context) {
    ui.platformViewRegistry.registerViewFactory(
      'adsenseType',
      (int viewId) => html.IFrameElement()
        ..width = '320'
        ..height = '100'
        ..src = 'adsense.html'
        ..style.border = 'none',
    );

    return SizedBox(
      width: 320,
      height: 100,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          HtmlElementView(
            viewType: 'adsenseType',
          ),
          Text(
            'AD',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}
