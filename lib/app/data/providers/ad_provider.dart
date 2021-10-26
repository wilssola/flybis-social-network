// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/app/app.dart';

class AdProvider {
  AdProvider._();
  static final AdProvider instance = AdProvider._();

  String getNativeAdmobId({
    String pageId = 'default',
  }) {
    try {
      pageId = pageId.toLowerCase();

      // Generic Test iOS AD ID from https://developers.google.com/admob/ios/native/start
      String iosAdIdTest = remoteConfig.getString('ios_ad_id_test');
      // Generic Test Android AD ID from https://developers.google.com/admob/android/native/start
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

      return '';
    } catch (error) {
      return getNativeAdmobId();
    }
  }
}
