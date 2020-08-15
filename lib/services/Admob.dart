import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flybis/widgets/Progress.dart';

class Admob extends StatefulWidget {
  final NativeAdmobType type;
  final double height;
  final Color color;
  final bool showButton;
  final double paddingTop, paddingBottom, paddingLeft, paddingRight;

  Admob({
    this.type,
    this.height = 100,
    this.color = Colors.black,
    this.showButton = true,
    this.paddingTop = 10,
    this.paddingBottom = 10,
    this.paddingLeft = 10,
    this.paddingRight = 10,
  });
  @override
  AdmobState createState() => AdmobState();
}

class AdmobState extends State<Admob> {
  final nativeAdController = !kIsWeb ? NativeAdmobController() : null;
  double height = 0;

  StreamSubscription subscription;
  AdvertisingService advertisingService = AdvertisingService();

  @override
  void initState() {
    if (!kIsWeb) {
      subscription = nativeAdController.stateChanged.listen(onStateChanged);
    }

    super.initState();
  }

  @override
  void dispose() {
    if (!kIsWeb) {
      subscription.cancel();
      nativeAdController.dispose();
    }

    super.dispose();
  }

  void onStateChanged(AdLoadState state) {
    switch (state) {
      case AdLoadState.loading:
        setState(() {
          height = widget.height;
        });
        break;

      case AdLoadState.loadCompleted:
        setState(() {
          height = widget.height;
        });
        break;

      case AdLoadState.loadError:
        setState(() {
          //height = 0;
          nativeAdController.reloadAd();
        });
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        height: height,
        color: Colors.white,
        margin: EdgeInsets.zero,
        padding: EdgeInsets.only(
          top: widget.paddingTop,
          bottom: widget.paddingBottom,
          left: widget.paddingLeft,
          right: widget.paddingRight,
        ),
        child: NativeAdmob(
          controller: nativeAdController,
          adUnitID: advertisingService.nativeAdId(),
          loading: circularProgress(context, color: widget.color),
          error: circularProgress(context, color: Colors.black),
          type: widget.type,
          options: NativeAdmobOptions(
            callToActionStyle: NativeTextStyle(
              backgroundColor: Color(widget.color.value),
              isVisible: widget.showButton,
            ),
            adLabelTextStyle: NativeTextStyle(
              backgroundColor: Color(widget.color.value),
            ),
          ),
        ),
      );
    }

    return Text('');
  }
}

class AdvertisingService {
  // Generic Test AD ID from https://developers.google.com/admob/android/native/start
  String testAdId = 'ca-app-pub-3940256099942544/2247696110';

  // Flybis Native AD ID
  String androidAdId = 'ca-app-pub-5982775373849971/8842878947';
  String iosAdId = 'ca-app-pub-5982775373849971/2711024365';

  String nativeAdId() {
    if (!kReleaseMode) {
      return testAdId;
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
