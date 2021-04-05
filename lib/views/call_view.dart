// Dart

// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;

// 🌎 Project imports:
import 'package:flybis/setting.dart';

class CallView extends StatefulWidget {
  final String chat, callId;

  CallView({
    @required this.chat,
    @required this.callId,
  });

  @override
  CallViewState createState() => CallViewState();
}

class CallViewState extends State<CallView> {
  bool isInChannel = false;
  final infoStrings = <String>[];

  static final _sessions = List<VideoSession>();
  String dropdownValue = 'Off';

  final List<String> voices = [
    'Off',
    'Oldman',
    'BabyBoy',
    'BabyGirl',
    'Zhubajie',
    'Ethereal',
    'Hulk'
  ];

  /// remote user list
  final _remoteUsers = List<int>();

  RtcEngine engine;

  @override
  void initState() {
    super.initState();

    initAgoraRtcEngine();
    addAgoraEventHandlers();
  }

  Future<void> initAgoraRtcEngine() async {
    engine = await RtcEngine.createWithConfig(RtcEngineConfig(AGORA_APP_ID));

    await engine.enableVideo();
    await engine.enableAudio();
    //AgoraRtcEngine.setParameters('{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}');
    await engine.setChannelProfile(ChannelProfile.Communication);

    VideoEncoderConfiguration config = VideoEncoderConfiguration();
    config.orientationMode = VideoOutputOrientationMode.FixedPortrait;
    await engine.setVideoEncoderConfiguration(config);
  }

  void addAgoraEventHandlers() {
    /*AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        String info = 'onJoinChannel: ' + channel + ', uid: ' + uid.toString();
        infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        infoStrings.add('onLeaveChannel');
        _remoteUsers.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (
      int uid,
      int elapsed,
    ) {
      setState(() {
        String info = 'userJoined: ' + uid.toString();
        infoStrings.add(info);
        _remoteUsers.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (
      int uid,
      int reason,
    ) {
      setState(() {
        String info = 'userOffline: ' + uid.toString();
        infoStrings.add(info);
        _remoteUsers.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        String info = 'firstRemoteVideo: ' +
            uid.toString() +
            ' ' +
            width.toString() +
            'x' +
            height.toString();
        infoStrings.add(info);
      });
    };*/
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Agora Flutter SDK'),
        ),
        body: Container(
          child: Column(
            children: [
              Container(height: 320, child: _viewRows()),
              OutlineButton(
                child: Text(isInChannel ? 'Leave Channel' : 'Join Channel',
                    style: textStyle),
                onPressed: toggleChannel,
              ),
              Container(height: 100, child: _voiceDropdown()),
              Expanded(child: Container(child: _buildInfoList())),
            ],
          ),
        ),
      ),
    );
  }

  Widget _voiceDropdown() {
    return Scaffold(
      body: Center(
        child: DropdownButton<String>(
          value: dropdownValue,
          onChanged: (String newValue) {
            setState(() {
              dropdownValue = newValue;
              AudioVoiceChanger voice =
                  AudioVoiceChanger.values[(voices.indexOf(dropdownValue))];
              engine.setLocalVoiceChanger(voice);
            });
          },
          items: voices.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }

  void toggleChannel() {
    setState(() async {
      if (isInChannel) {
        isInChannel = false;
        await engine.leaveChannel();
        await engine.stopPreview();
      } else {
        isInChannel = true;
        await engine.startPreview();
        await engine.joinChannel(
          null,
          widget.chat + '-' + widget.callId,
          null,
          0,
        );
      }
    });
  }

  Widget _viewRows() {
    return Row(
      children: <Widget>[
        for (final widget in _renderWidget)
          Expanded(
            child: Container(
              child: widget,
            ),
          )
      ],
    );
  }

  Iterable<Widget> get _renderWidget sync* {
    yield RtcLocalView.SurfaceView(
      channelId: widget.callId,
    );

    for (final uid in _remoteUsers) {
      yield RtcRemoteView.SurfaceView(
        uid: uid,
      );
    }
  }

  VideoSession _getVideoSession(int uid) {
    return _sessions.firstWhere((session) {
      return session.uid == uid;
    });
  }

  List<Widget> _getRenderViews() {
    return _sessions.map((session) => session.view).toList();
  }

  static TextStyle textStyle = TextStyle(fontSize: 18, color: Colors.blue);

  Widget _buildInfoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemExtent: 24,
      itemBuilder: (context, i) {
        return ListTile(
          title: Text(infoStrings[i]),
        );
      },
      itemCount: infoStrings.length,
    );
  }
}

class VideoSession {
  int uid;
  Widget view;
  int viewId;

  VideoSession(int uid, Widget view) {
    this.uid = uid;
    this.view = view;
  }
}
