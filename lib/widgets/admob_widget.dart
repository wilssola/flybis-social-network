// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:device_info/device_info.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/widgets/utils_widget.dart' deferred as utils_widget;

import 'package:flybis/widgets/custom_ad_widget.dart'
    deferred as custom_ad_widget;

Future<bool> loadLibraries() async {
  await utils_widget.loadLibrary();
  await custom_ad_widget.loadLibrary();

  return true;
}

enum AdmobSize {
  banner,
  fullBanner,
  largeBanner,
  leaderboard,
  mediumRectangle,
}

class AdmobWidget extends StatefulWidget {
  final String? adUnitId;
  final AdmobSize size;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? pageColor;

  AdmobWidget({
    required this.adUnitId,
    this.size = AdmobSize.largeBanner,
    this.margin,
    this.padding,
    this.pageColor,
  });

  @override
  _AdmobWidgetState createState() => _AdmobWidgetState();
}

class _AdmobWidgetState extends State<AdmobWidget> {
  BannerAd? _ad;
  late AdSize _size;
  double? _width, _height;
  bool _loaded = false;
  EdgeInsetsGeometry? _margin = EdgeInsets.zero;
  EdgeInsetsGeometry? _padding = EdgeInsets.zero;

  bool _useVirtualDisplay = false;

  final String adUnitId = Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/6300978111'
      : 'ca-app-pub-3940256099942544/2934735716';

  @override
  void initState() {
    super.initState();

    initAd();
  }

  void initAd() async {
    switch (widget.size) {
      case (AdmobSize.banner):
        _size = AdSize.banner;
        _width = 320;
        _height = 50;
        break;
      case (AdmobSize.fullBanner):
        _size = AdSize.fullBanner;
        _width = 468;
        _height = 60;
        break;
      case (AdmobSize.largeBanner):
        _size = AdSize.largeBanner;
        _width = 320;
        _height = 100;
        break;
      case (AdmobSize.leaderboard):
        _size = AdSize.leaderboard;
        _width = 728;
        _height = 90;
        break;
      case (AdmobSize.mediumRectangle):
        _size = AdSize.mediumRectangle;
        _width = 300;
        _height = 250;
        break;
      default:
        _size = AdSize.largeBanner;
        _width = 320;
        _height = 100;
    }

    _margin = widget.margin != null ? widget.margin : _margin;
    _padding = widget.padding != null ? widget.padding : _padding;

    if (!kIsWeb) {
      // Prior to Android 10 AndroidView Should have better performance.
      // https://flutter.dev/docs/development/platform-integration/platform-views#performance
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      if (mounted) {
        setState(() {
          _useVirtualDisplay = androidInfo.version.sdkInt <= 28;
        });
      }

      //  Create a BannerAd instance
      _ad = BannerAd(
        adUnitId: adUnitId, //widget.adUnitId,
        size: _size,
        request: AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (mounted) {
              setState(() {
                _loaded = true;
                _width = _ad!.size.width.toDouble() * 1.1;
                _height = _ad!.size.height.toDouble() * 1.1;
                _margin = widget.margin != null ? widget.margin : _margin;
                _padding = widget.padding != null ? widget.padding : _padding;
              });
            }

            logger.i(
              'onAdLoaded: (adUnitId=${ad.adUnitId})',
            );
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            logger.e(
              'onAdFailedToLoad: (code=${error.code} message=${error.message})',
            );

            if (mounted) {
              setState(() {
                _height = 0;
              });
            }
          },
        ),
      );

      //  Load an ad
      _ad!.load();
    } else {
      if (mounted) {
        setState(() {
          _height = 0;
        });
      }
    }
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      _ad?.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        return _loaded
            ? Container(
                width: _width,
                height: _height,
                margin: _margin,
                padding: _padding,
                alignment: Alignment.center,
                child: custom_ad_widget.CustomAdWidget(
                  ad: _ad!,
                  useVirtualDisplay: _useVirtualDisplay,
                ),
              )
            : Container(
                width: _width! * 1.1,
                height: _height! * 1.1,
                margin: _margin,
                padding: _padding,
                alignment: Alignment.center,
                child: utils_widget.UtilsWidget()
                    .circularProgress(context, color: widget.pageColor),
              );
      },
    );
  }
}
