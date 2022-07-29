// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/providers/ad_provider.dart';
import 'package:flybis/app/widgets/admob_widget.dart';
import 'package:flybis/app/widgets/adsense_widget.dart';

class AdWidget extends StatelessWidget {
  final AdProvider _ad = AdProvider.instance;

  final String pageId;
  final Color pageColor;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  AdWidget({
    this.pageId = 'default',
    required this.pageColor,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const AdsenseWidget();
    }

    if (Platform.isIOS || Platform.isAndroid) {
      return AdmobWidget(
        adUnitId: _ad.getNativeAdmobId(pageId: pageId),
        margin: margin,
        padding: padding,
        pageColor: pageColor,
      );
    }

    return Container(padding: EdgeInsets.zero);
  }
}
