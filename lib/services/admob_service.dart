// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/app.dart';
import 'package:flybis/services/adsense_service.dart';
import 'package:flybis/widgets/admob_widget.dart';

class AdmobService {
  Widget showAdmob({
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    String pageId = 'default',
    required Color? pageColor,
  }) {
    if (kIsWeb) {
      return AdsenseService().showAdsense();
    }

    return AdmobWidget(
      adUnitId: nativeAdmobId(pageId),
      margin: margin,
      padding: padding,
      pageColor: pageColor,
    );
  }

  String? nativeAdmobId(String pageId) {
    pageId = pageId.toLowerCase();

    // Generic Test AD ID from https://developers.google.com/admob/ios/native/start
    String iosAdIdTest = remoteConfig.getString('ios_ad_id_test');
    // Generic Test AD ID from https://developers.google.com/admob/android/native/start
    String androidAdIdTest = remoteConfig.getString('android_ad_id_test');

    // Flybis Native iOS AD ID
    String iosAdId = remoteConfig.getString('ios_ad_id_' + pageId);
    // Flybis Native Android AD ID
    String androidAdId = remoteConfig.getString('android_ad_id_' + pageId);

    if (!kReleaseMode) {
      if (Platform.isIOS) {
        return iosAdIdTest;
      }

      if (Platform.isAndroid) {
        return androidAdIdTest;
      }
    } else {
      if (Platform.isIOS) {
        return iosAdId;
      }

      if (Platform.isAndroid) {
        return androidAdId;
      }
    }

    return null;
  }
}
