import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flutter_native_admob/native_admob_options.dart';
import 'package:flutter_native_admob/native_admob_controller.dart';
import 'package:flybis/widgets/Progress.dart';

void bannerToList(List list, int diference, Widget child) {
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
  final nativeAdController = NativeAdmobController();
  double height = 0;

  StreamSubscription subscription;

  @override
  void initState() {
    subscription = nativeAdController.stateChanged.listen(onStateChanged);
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    nativeAdController.dispose();
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

      default:
        break;
    }
  }

  AdvertisingService advertisingService = AdvertisingService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: EdgeInsets.only(
        top: widget.paddingTop,
        bottom: widget.paddingBottom,
        left: widget.paddingLeft,
        right: widget.paddingRight,
      ),
      margin: EdgeInsets.zero,
      child: NativeAdmob(
        adUnitID: advertisingService.nativeAdId(),
        controller: nativeAdController,
        loading: circularProgress(color: widget.color),
        error: Container(),
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
}

class AdvertisingService {
  // Generic Test AD ID from https://developers.google.com/admob/android/native/start
  String testAdId = 'ca-app-pub-3940256099942544/2247696110';
  String androidAdId = 'ca-app-pub-8623599289446269/4433503877';
  String iosAdId = '';

  String nativeAdId() {
    if (isInDebugMode) {
      return testAdId;
    }

    if (Platform.isIOS) {
      return iosAdId;
    }

    return androidAdId;
  }

  bool get isInDebugMode {
    bool inDebugMode = false;
    assert(inDebugMode = true);
    return inDebugMode;
  }
}
