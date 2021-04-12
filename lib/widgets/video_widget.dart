// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import "package:flutter/material.dart";
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import "package:universal_io/io.dart" as io;
import "package:video_player/video_player.dart";
import 'package:better_player/better_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:universal_html/html.dart' as html;
import 'package:visibility_detector/visibility_detector.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/plugins/ui/ui.dart' as ui;
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

enum VideoSourceType { hls, url, file }

class VideoWidget extends StatefulWidget {
  final VideoSourceType type;
  final String source;
  final String title, author, imageUrl;
  final Function onDoubleTap;

  VideoWidget({
    @required this.type,
    @required this.source,
    this.title,
    this.author,
    this.imageUrl,
    this.onDoubleTap,
  });

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  BetterPlayerDataSource betterPlayerDataSource;
  BetterPlayerController _betterPlayerController;

  html.VideoElement _videoElement = html.VideoElement();

  final Key _playerKey = GlobalKey();

  final bool isAndroidOrIos = !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();

    prepareVideo();
  }

  Future<void> prepareVideo() async {
    logger.d('widget.title: ${widget.title}');
    logger.d('widget.author: ${widget.author}');

    if (widget.type == VideoSourceType.hls) {
      if (isAndroidOrIos) {
        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.source,
          //videoFormat: BetterPlayerVideoFormat.hls,
          cacheConfiguration: BetterPlayerCacheConfiguration(
            useCache: true,
          ),
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.title,
            author: widget.author,
            imageUrl: widget.imageUrl,
          ),
        );
      } else {
        _videoPlayerController = VideoPlayerController.network(
          widget.source,
        );
      }
    } else if (widget.type == VideoSourceType.url) {
      FileInfo fileInfo = await DefaultCacheManager().downloadFile(
        widget.source,
      );

      if (isAndroidOrIos) {
        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          fileInfo.file.path,
          //videoFormat: BetterPlayerVideoFormat.dash,
          notificationConfiguration: BetterPlayerNotificationConfiguration(
            showNotification: true,
            title: widget.title,
            author: widget.author,
            imageUrl: widget.imageUrl,
          ),
        );
      } else {
        _videoPlayerController = VideoPlayerController.file(
          fileInfo.file,
        );
      }
    } else if (widget.type == VideoSourceType.file) {
      if (isAndroidOrIos) {
        betterPlayerDataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          widget.source,
          //videoFormat: BetterPlayerVideoFormat.other,
        );
      } else {
        _videoPlayerController = VideoPlayerController.file(
          File(widget.source),
        );
      }
    }

    if (isAndroidOrIos) {
      _betterPlayerController = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 1,
          fit: BoxFit.contain,
          autoDetectFullscreenDeviceOrientation: true,
          controlsConfiguration: BetterPlayerControlsConfiguration(
            enablePip: true,
            overflowMenuCustomItems: [
              BetterPlayerOverflowMenuItem(
                Icons.picture_in_picture,
                "PiP",
                () async {
                  try {
                    if (await _betterPlayerController
                        .isPictureInPictureSupported()) {
                      _betterPlayerController
                          .enablePictureInPicture(_playerKey);
                    }
                  } catch (error) {
                    logger.e(error);
                  }
                },
              ),
            ],
          ),
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      if (_betterPlayerController != null) {
        _betterPlayerController
            .setOverriddenAspectRatio(_betterPlayerController.getAspectRatio());
      }
    } else {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoPlay: true,
        looping: true,
      );
    }

    if (_videoPlayerController != null) {
      await _videoPlayerController.initialize();
    }
  }

  Widget htmlPlayer() {
    final String hashCode = widget.source.hashCode.toString();

    _videoElement.src = widget.source;
    _videoElement.controls = true;

    ui.platformViewRegistry.registerViewFactory(
      'videoElement_$hashCode',
      (int viewId) => _videoElement,
    );

    return HtmlElementView(
      key: ValueKey(hashCode),
      viewType: "videoElement_$hashCode",
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.source),
      onVisibilityChanged: (VisibilityInfo visibilityInfo) {
        final double visiblePercentage = visibilityInfo.visibleFraction * 100;

        if (visiblePercentage <= 50) {
          if (isAndroidOrIos && _betterPlayerController != null) {
            _betterPlayerController.pause();
          } else if (_chewieController != null) {
            _videoElement.pause();
            _chewieController.pause();
          }
        } else {
          if (isAndroidOrIos && _betterPlayerController != null) {
            _betterPlayerController.play();
          } else if (_chewieController != null) {
            _videoElement.play();
            _chewieController.play();
          }
        }
      },
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth:
                !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
            maxWidth:
                !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
            minHeight:
                !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
            maxHeight:
                !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
          ),
          child: AspectRatio(
            aspectRatio: isAndroidOrIos
                ? _betterPlayerController != null
                    ? _betterPlayerController
                        .videoPlayerController.value.aspectRatio
                    : 1
                : _videoPlayerController != null
                    ? _videoPlayerController.value.aspectRatio
                    : 1,
            child: isAndroidOrIos
                ? BetterPlayer(
                    key: _playerKey,
                    controller: _betterPlayerController,
                  )
                //: kIsWeb
                //? htmlPlayer()
                : Chewie(
                    key: _playerKey,
                    controller: _chewieController,
                  ),
          ),
        ),
      ),
    );
  }
}
