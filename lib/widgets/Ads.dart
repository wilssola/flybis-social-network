import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flybis/widgets/Progress.dart';

import 'package:flybis/widgets/Utils.dart';

import 'package:native_ads/native_ad_param.dart';
import 'package:native_ads/native_ad_view.dart';

String getBannerAdUnitId() {
  if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/2934735716';
  } else if (Platform.isAndroid) {
    return 'ca-app-pub-3940256099942544/6300978111';
  }

  return null;
}

Widget banner() {
  return NativeAdViewWrapper();
}

Widget bannerGrid() {
  return TileNativeAdViewWrapper();
}

Widget bannerMedia() {
  return NativeAdViewWrapper();
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

class NativeAdViewWrapper extends StatefulWidget {
  const NativeAdViewWrapper();

  @override
  NativeAdViewWrapperState createState() => NativeAdViewWrapperState();
}

class NativeAdViewWrapperState extends State<NativeAdViewWrapper>
    with AutomaticKeepAliveClientMixin {
  NativeAdViewController _controller;

  bool onAdFailedToLoad = false;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 350,
        child: NativeAdView(
          onParentViewCreated: (_) {},
          androidParam: AndroidParam()
            ..placementId = "ca-app-pub-3940256099942544/2247696110"
            ..packageName = "com.tecwolf.flybis"
            ..layoutName = "native_ad_layout"
            ..attributionText = "",
          iosParam: IOSParam()
            ..placementId = "ca-app-pub-3940256099942544/3986624511"
            ..bundleId = "com.tecwolf.flybis"
            ..layoutName = "UnifiedNativeAdView"
            ..attributionText = "",
          onAdImpression: () => print("onAdImpression"),
          onAdClicked: () => print("onAdClicked"),
          onAdFailedToLoad: (Map<String, dynamic> error) {
            print("onAdFailedToLoad: $error");

            setState(() {
              onAdFailedToLoad = true;
            });
          },
        ),
      ),
    );
  }
}

class TileNativeAdViewWrapper extends StatefulWidget {
  const TileNativeAdViewWrapper();

  @override
  TileNativeAdViewWrapperState createState() => TileNativeAdViewWrapperState();
}

class TileNativeAdViewWrapperState extends State<TileNativeAdViewWrapper>
    with AutomaticKeepAliveClientMixin {
  NativeAdViewController _controller;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: EdgeInsets.zero,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: NativeAdView(
          onParentViewCreated: (_) {},
          androidParam: AndroidParam()
            ..placementId = "ca-app-pub-3940256099942544/2247696110"
            ..packageName = "com.tecwolf.flybis"
            ..layoutName = "small_ad_layout"
            ..attributionText = "",
          iosParam: IOSParam()
            ..placementId = "ca-app-pub-3940256099942544/3986624511"
            ..bundleId = "com.tecwolf.flybis"
            ..layoutName = "UnifiedNativeAdView"
            ..attributionText = "",
          onAdImpression: () => print("onAdImpression"),
          onAdClicked: () => print("onAdClicked"),
          onAdFailedToLoad: (Map<String, dynamic> error) =>
              print("onAdFailedToLoad: $error"),
        ),
      ),
    );
  }
}
