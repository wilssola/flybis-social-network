// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_html/html.dart';
import 'package:universal_html/js.dart' as js;

// 🌎 Project imports:
import 'package:flybis/plugins/ui/ui.dart' as ui;

class AgoraWeb {
  bool hostPresent = false;
  bool videoPlaying = false;
  int? hostUid;

  void registerVideoPlayer() {
    // ignore:undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory('video-container',
        (int viewId) {
      final div = DivElement()..id = 'video-container';

      return div;
    });
  }

  void callJsMethod({required String method, List<String>? args}) {
    print("Calling method: $method");
    js.context.callMethod(method, args);
  }

  void goToSleep(int milliseconds) {
    callJsMethod(method: 'goToSleep', args: [milliseconds.toString()]);
  }

  Future<void> joinSession({
    required String sessionId,
    required String token,
    required String clientType,
    required String clientAccount,
    Function? hostJoinCallback,
  }) async {
    callJsMethod(
      method: 'joinSession',
      args: [sessionId, clientType, token, clientAccount],
    );
  }

  Future<void> leaveSession() async {
    callJsMethod(method: 'leaveSession', args: []);
    goToSleep(500);
  }

  Future<void> refreshStream() async {
    callJsMethod(method: 'refreshStream', args: []);
  }

  void startHosting(String sessionId) {
    callJsMethod(method: 'startHosting', args: [sessionId]);
  }

  void stopHosting() {
    callJsMethod(method: 'stopHosting', args: []);
  }
}

getAgoraController() => AgoraWeb();

/// Actually using the component

class HostContainer extends StatelessWidget {
  HostContainer(this.provider, this.sessionId, this.clientType) {
    provider.agoraController.registerVideoPlayer();
  }

  final provider;
  final String sessionId;
  final clientType;

  @override
  Widget build(context) {
    return PlatformHostContainer(provider, sessionId, clientType);
  }
}

/// Web implementation

class PlatformHostContainer extends StatelessWidget {
  PlatformHostContainer(this.provider, this.sessionId, this.clientType);

  final provider;
  final String sessionId;
  final clientType;

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(
      viewType: 'video-container',
    );
  }
}
