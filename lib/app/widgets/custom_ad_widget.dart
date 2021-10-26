// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

// 📦 Package imports:
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_mobile_ads/src/ad_instance_manager.dart';

// ignore: implementation_imports

// ORIGINAL: https://github.com/googleads/googleads-mobile-flutter/blob/master/packages/google_mobile_ads/lib/src/ad_containers.dart
class CustomAdWidget extends StatefulWidget {
  const CustomAdWidget(
      {Key? key, required this.ad, this.useVirtualDisplay = false})
      : assert(ad != null),
        super(key: key);

  final AdWithView ad;
  final bool useVirtualDisplay;

  @override
  _CustomAdWidgetState createState() => _CustomAdWidgetState();
}

class _CustomAdWidgetState extends State<CustomAdWidget> {
  bool _adIdAlreadyMounted = false;

  @override
  void initState() {
    super.initState();
    final int adId = instanceManager.adIdFor(widget.ad)!;
    if (instanceManager.isWidgetAdIdMounted(adId)) {
      _adIdAlreadyMounted = true;
    }
    instanceManager.mountWidgetAdId(adId);
  }

  @override
  void dispose() {
    final int adId = instanceManager.adIdFor(widget.ad)!;
    instanceManager.unmountWidgetAdId(adId);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_adIdAlreadyMounted) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('This AdWidget is already in the Widget tree'),
        ErrorHint(
            'If you placed this AdWidget in a list, make sure you create a new instance '
            'in the builder function with a unique ad object.'),
        ErrorHint(
            'Make sure you are not using the same ad object in more than one AdWidget.'),
      ]);
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (widget.useVirtualDisplay) {
        // Prior to Android 10 AndroidView Should have better performance.
        // https://flutter.dev/docs/development/platform-integration/platform-views#performance
        return AndroidView(
          viewType: '${instanceManager.channel.name}/ad_widget',
          creationParamsCodec: const StandardMessageCodec(),
          creationParams: instanceManager.adIdFor(widget.ad),
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
        );
      } else {
        return PlatformViewLink(
          viewType: '${instanceManager.channel.name}/ad_widget',
          surfaceFactory:
              (BuildContext context, PlatformViewController controller) {
            return AndroidViewSurface(
              controller: controller as AndroidViewController,
              gestureRecognizers: const <
                  Factory<OneSequenceGestureRecognizer>>{},
              hitTestBehavior: PlatformViewHitTestBehavior.opaque,
            );
          },
          onCreatePlatformView: (PlatformViewCreationParams params) {
            return PlatformViewsService.initSurfaceAndroidView(
              id: params.id,
              viewType: '${instanceManager.channel.name}/ad_widget',
              layoutDirection: TextDirection.ltr,
              creationParams: instanceManager.adIdFor(widget.ad),
              creationParamsCodec: StandardMessageCodec(),
            )
              ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
              ..create();
          },
        );
      }
    }

    return UiKitView(
      viewType: '${instanceManager.channel.name}/ad_widget',
      creationParams: instanceManager.adIdFor(widget.ad),
      creationParamsCodec: StandardMessageCodec(),
    );
  }
}
