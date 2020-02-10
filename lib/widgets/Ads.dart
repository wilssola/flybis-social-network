import 'dart:io';
import 'package:flutter/cupertino.dart';

import 'package:flybis/widgets/Text.dart';

import 'package:native_admob/native_admob.dart';

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return "ca-app-pub-3940256099942544/8135179316";
  }

  return "ca-app-pub-3940256099942544/8135179316";
}

Widget banner() {
  return NativeAdmobBannerView(
    adUnitID: getBannerAdUnitId(),
    style: BannerStyle.light, // enum dark or light
    showMedia: false, // whether to show media view or not
  );
}

Widget bannerMedia() {
  return NativeAdmobBannerView(
    adUnitID: getBannerAdUnitId(),
    style: BannerStyle.light, // enum dark or light
    showMedia: true, // whether to show media view or not
  );
}

bannerToList(List list, int diference, Widget child) {
  if (diference > 0) {
    for (var i = 0; i < list.length; i++) {
      if (i % (diference + 1) == 0) {
        list.insert(i, child);
      }
    }
  } else {
    list.insert(0, child);
  }
}

bannerWithChild(String text, {List list}) {
  if (list != null) {
    list.insert(0, bannerMedia());
    list.insert(1, infoText(text));
  } else {
    return ListView(
      children: <Widget>[
        bannerMedia(),
        infoText(text),
      ],
    );
  }
}

enum AdsType { BANNER, BANNER_MEDIUM }

class Ads extends StatefulWidget {
  final AdsType type;

  Ads(this.type);

  @override
  _AdsState createState() => _AdsState();
}

class _AdsState extends State<Ads> {
  @override
  Widget build(BuildContext context) {
    if (widget.type == AdsType.BANNER) {
      return banner();
    } else if (widget.type == AdsType.BANNER_MEDIUM) {
      return bannerMedia();
    }

    return null;
  }
}
