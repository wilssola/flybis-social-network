import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flybis/widgets/Progress.dart';

import 'package:flybis/widgets/Text.dart';

import 'package:admob_flutter/admob_flutter.dart';

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }
}

Widget banner() {
  return Padding(padding: EdgeInsets.zero,);

  return Stack(
    children: <Widget>[
      Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: Center(
          child: circularProgress(),
        ),
      ),
      Padding(
        padding: EdgeInsets.all(15),
        child: AdmobBanner(
          adUnitId: getBannerAdUnitId(),
          adSize: AdmobBannerSize.BANNER,
        ),
      ),
    ],
  );
}

Widget bannerGrid() {
  return Padding(padding: EdgeInsets.zero,);

  return Container(
    child: Stack(
      children: <Widget>[
        AdmobBanner(
          adUnitId: getBannerAdUnitId(),
          adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
        ),
      ],
    ),
  );
}

Widget bannerMedia() {
  return Padding(padding: EdgeInsets.zero,);

  return Padding(
    padding: EdgeInsets.all(15),
    child: Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: circularProgress(),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(15),
          child: AdmobBanner(
            adUnitId: getBannerAdUnitId(),
            adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
          ),
        ),
      ],
    ),
  );
}

bannerToList(List list, int diference, Widget child) {
  return null;

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
