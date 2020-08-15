import "dart:io";

import 'package:flutter/foundation.dart';
import "package:flutter/material.dart";
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flybis/const.dart';
import "package:video_player/video_player.dart";
import "package:flutter_widgets/flutter_widgets.dart";
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'Header.dart';

class VideoWidget extends StatefulWidget {
  final bool hls;
  final File file;
  final String url;
  final Function onDoubleTap;

  VideoWidget({
    this.hls = true,
    this.url,
    this.file,
    this.onDoubleTap,
  });

  @override
  VideoWidgetState createState() => VideoWidgetState();
}

class VideoWidgetState extends State<VideoWidget> {
  double aspectRatio = 0;
  VideoPlayerController controller;

  bool showButton = false;
  bool videoEnded = false;
  bool buttonDisabled = true;
  bool buttonPressed = false;

  @override
  void initState() {
    super.initState();

    prepareVideo();
  }

  void prepareVideo() async {
    if (widget.url != null) {
      if (widget.hls) {
        controller = VideoPlayerController.network(widget.url);
      } else {
        FileInfo fileInfo =
            await DefaultCacheManager().downloadFile(widget.url);
        controller = VideoPlayerController.file(fileInfo.file);
      }
    } else if (widget.file != null) {
      controller = VideoPlayerController.file(widget.file);
    }

    if (controller != null) {
      controller.addListener(checkVideo);

      await initializeVideo();
    }
  }

  Future initializeVideo() async {
    await controller.initialize();

    setState(() {
      aspectRatio = controller.value.aspectRatio;
      videoEnded = false;
    });
  }

  void checkVideo() {
    if (controller.value.position ==
        Duration(
          seconds: 0,
          minutes: 0,
          hours: 0,
        )) {
      setState(() {
        videoEnded = false;
      });
    }

    if (controller.value.position == controller.value.duration) {
      setState(() {
        buttonDisabled = false;
        showButton = true;
        videoEnded = true;
      });
    }
  }

  void switchVideo() {
    setState(() {
      if (!buttonDisabled || !buttonPressed) {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          if (!videoEnded) {
            controller.play();
          } else {
            initializeVideo();
            controller.play();
          }
        }
      }

      buttonPressed = true;
    });

    hideButton();
  }

  void switchButton() {
    setState(() {
      showButton = true;
      buttonDisabled = false;
    });

    hideButton();
  }

  void hideButton() {
    Future.delayed(Duration(milliseconds: 1000)).then((value) {
      setState(() {
        showButton = false;
      });

      Future.delayed(Duration(milliseconds: 500)).then((value) {
        setState(() {
          buttonDisabled = true;
        });
      });
    });
  }

  Widget backgroundVideo() {
    return Container(
      color: Colors.black,
      width: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      height: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
    );
  }

  Widget loadingVideo() {
    return Stack(
      children: <Widget>[
        backgroundVideo(),
        Positioned(
          top: 0,
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ],
    );
  }

  Widget videoPlayer(BuildContext context, bool fullscreen) {
    return VisibilityDetector(
      key: Key(widget.url != null ? widget.url : widget.file.path),
      onVisibilityChanged: (VisibilityInfo info) {
        setState(() {
          if (controller != null) {
            if (controller.value.initialized) {
              if (info.visibleFraction > 0.5) {
                if (!buttonPressed) {
                  //controller.play();
                }
              } else {
                controller.pause();
              }
            }
          }
        });
      },
      child: GestureDetector(
        onTap: switchButton,
        onDoubleTap: widget.onDoubleTap,
        child: controller != null
            ? controller.value.initialized
                ? Stack(
                    children: <Widget>[
                      backgroundVideo(),
                      Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: controller.value.aspectRatio,
                            child: VideoPlayer(controller),
                          ),
                        ),
                      ),
                      !buttonDisabled || !buttonPressed
                          ? Positioned(
                              top: 0,
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: AnimatedOpacity(
                                  opacity:
                                      showButton || !buttonPressed ? 1.0 : 0.0,
                                  duration: Duration(
                                    milliseconds: 500,
                                  ),
                                  child: FloatingActionButton(
                                    backgroundColor: Colors.white.withOpacity(
                                      0.75,
                                    ),
                                    onPressed: switchVideo,
                                    child: Icon(
                                      !videoEnded
                                          ? controller.value.isPlaying
                                              ? Icons.pause
                                              : Icons.play_arrow
                                          : Icons.refresh,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.zero,
                            ),
                      Positioned(
                        bottom: 15,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            if (!fullscreen) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: header(context, titleText: ""),
                                    body: Container(
                                      height:
                                          MediaQuery.of(context).size.height,
                                      width: MediaQuery.of(context).size.width,
                                      child: videoPlayer(context, true),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          child: Icon(
                            !fullscreen
                                ? FeatherIcons.maximize
                                : FeatherIcons.minimize,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                        ),
                      ),
                    ],
                  )
                : loadingVideo()
            : loadingVideo(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayer(context, false);
  }
}
