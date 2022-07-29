// 🌎 Project imports:
import 'package:flybis/global.dart';

class FlybisTokenMessaging {
  String? androidToken, electronToken, iosToken, webToken;

  FlybisTokenMessaging({
    this.androidToken = '',
    this.electronToken = '',
    this.iosToken = '',
    this.webToken = '',
  });

  factory FlybisTokenMessaging.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    if (data == null) {
      return FlybisTokenMessaging();
    }

    logger.d('FlybisTokenMessaging.fromMap: ' + data.toString());

    return FlybisTokenMessaging(
      androidToken: data['androidToken'],
      electronToken: data['electronToken'],
      iosToken: data['iosToken'],
      webToken: data['webToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'androidToken': androidToken,
      'electronToken': electronToken,
      'iosToken': iosToken,
      'webToken': webToken,
    };
  }
}
