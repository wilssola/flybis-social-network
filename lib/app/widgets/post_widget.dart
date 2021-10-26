// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:animations/animations.dart';
import 'package:animator/animator.dart' as animator;
import 'package:carousel_slider/carousel_slider.dart' as carousel_slider;
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/values/function.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/document_model.dart';
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/format.dart' as format;
import 'package:flybis/app/data/services/post_service.dart';
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/app/views/comment_view.dart' deferred as comment_view;
import 'package:flybis/app/views/post_view.dart' deferred as post_view;
import 'package:flybis/app/views/profile_view.dart' deferred as profile_view;
import 'package:flybis/app/widgets/image_widget.dart' as image_widget;
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;
import 'package:flybis/app/widgets/video_widget.dart' as video_widget;

//  Package imports:
import 'package:flybis/plugins/image_network/image_network.dart'
    as image_network;

enum PostWidgetType { LIST, GRID }

Future<bool> loadLibraries() async {
  await post_view.loadLibrary();
  await comment_view.loadLibrary();
  await profile_view.loadLibrary();

  return true;
}

class PostWidget extends StatefulWidget {
  final FlybisPost flybisPost;
  final PostWidgetType postWidgetType;
  final Color? pageColor;

  PostWidget({
    required this.flybisPost,
    required this.postWidgetType,
    this.pageColor,
    required Key key,
  }) : super(key: key);

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  FlybisUser? _flybisUser = FlybisUser();

  bool? isLiked = false;
  bool? isDisliked = false;

  bool iconShow = false;
  Color? iconColor;
  IconData? iconData;

  int _contentIndex = 0;

  final carousel_slider.CarouselController _carouselController =
      carousel_slider.CarouselController();

  @override
  void initState() {
    if (widget.postWidgetType == PostWidgetType.LIST) {
      getUser();
      getLikeOrDislike();
    }

    super.initState();
  }

  Future<void> getUser() async {
    FlybisUser? flybisUser =
        await UserService().getUser(widget.flybisPost.userId);

    if (mounted) {
      setState(() {
        this._flybisUser = flybisUser;
      });
    }
  }

  Future<void> getLikeOrDislike() async {
    bool? isLiked = await PostService().getLike(
      widget.flybisPost.userId,
      widget.flybisPost.postId,
      flybisUserOwner!.uid,
    );
    bool? isDisliked = await PostService().getDislike(
      widget.flybisPost.userId,
      widget.flybisPost.postId,
      flybisUserOwner!.uid,
    );

    if (mounted) {
      setState(() {
        this.isLiked = isLiked;
        this.isDisliked = isDisliked;
      });
    }
  }

  void hideIcon() {
    Timer(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          this.iconShow = false;
        });
      }
    });
  }

  void handleLike() async {
    logger.i('handleLike');

    if (isLiked!) {
      await PostService().deleteLike(
        widget.flybisPost.userId,
        widget.flybisPost.postId,
        flybisUserOwner!.uid,
      );

      if (mounted) {
        setState(() {
          this.isLiked = false;
        });
      }
    } else if (!isLiked! && !isDisliked!) {
      await PostService().setLike(
        widget.flybisPost.userId,
        widget.flybisPost.postId,
        flybisUserOwner!.uid,
      );

      if (mounted) {
        setState(() {
          this.isLiked = true;
          this.iconColor = Colors.green;
          this.iconData = Icons.thumb_up;
          this.iconShow = true;
        });
      }

      hideIcon();
    }
  }

  void handleDislike() async {
    logger.i('handleDislike');

    if (isDisliked!) {
      PostService().deleteDislike(
        widget.flybisPost.userId,
        widget.flybisPost.postId,
        flybisUserOwner!.uid,
      );

      if (mounted) {
        setState(() {
          this.isDisliked = false;
        });
      }
    } else if (!isDisliked! && !isLiked!) {
      PostService().setDislike(
        widget.flybisPost.userId,
        widget.flybisPost.postId,
        flybisUserOwner!.uid,
      );

      if (mounted) {
        setState(() {
          this.isDisliked = true;
          this.iconColor = Colors.red;
          this.iconData = Icons.thumb_down;
          this.iconShow = true;
        });
      }

      hideIcon();
    }
  }

  void handleLikes() {
    logger.i('handleLikes');

    if (!isLiked! && !isDisliked!) {
      handleLike();
    } else if (isLiked! && !isDisliked!) {
      handleLike();
      handleDislike();
    } else if (!isLiked! && isDisliked!) {
      handleDislike();
    }
  }

  Future<void> delete() async {
    await PostService().deletePost(
      widget.flybisPost.userId,
      widget.flybisPost.postId,
    );
  }

  Future<void> options(BuildContext context, bool isOwner) {
    return showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text('Opções'),
        children: <Widget>[
          isOwner
              ? SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);

                    delete()
                        .then(
                          (value) => Get.snackbar(
                            'Flybis',
                            'Deletado com sucesso',
                          ),
                        )
                        .catchError(
                          (onError) => Get.snackbar(
                            'Flybis',
                            'Erro ao deletar',
                          ),
                        );
                  },
                  child: Text('Deletar'),
                )
              : Padding(padding: EdgeInsets.zero),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Denunciar'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          )
        ],
      ),
    );
  }

  Widget header(BuildContext context) {
    const double kHeaderHeight = 80;

    bool isOwner = flybisUserOwner!.uid == widget.flybisPost.userId;

    return Container(
      height: kHeaderHeight,
      width: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: kAvatarBackground,
          backgroundImage:
              image_network.ImageNetwork.cachedNetworkImageProvider(
            _flybisUser!.photoUrl!,
          ),
        ),
        title: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => profile_view.showProfile(
              context,
              uid: widget.flybisPost.userId,
              pageColor: widget.pageColor,
            ),
            child: _flybisUser!.username!.length > 0
                ? utils_widget.UtilsWidget()
                    .usernameText(_flybisUser!.username!)
                : utils_widget.UtilsWidget().shimmer(context, height: 17.5),
          ),
        ),
        subtitle: _flybisUser!.displayName!.length > 0
            ? Text(
                widget.flybisPost.postLocation!.length > 0
                    ? widget.flybisPost.postLocation!
                    : _flybisUser!.displayName!,
              )
            : utils_widget.UtilsWidget().shimmer(context, height: 17.5),
        trailing: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => options(context, isOwner),
            child: Icon(
              Icons.more_vert,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget content(BuildContext context) {
    double contentHeight =
        !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context);

    double iconSize = !kIsWeb
        ? MediaQuery.of(context).size.width * 0.25
        : MediaQuery.of(context).size.width * 0.125;

    List<Widget> contents = [];

    for (int i = 0; i < widget.flybisPost.postContents!.length; i++) {
      Widget content;

      if (widget.flybisPost.postContents![i].contentType == 'image') {
        content = image_widget.ImageWidget(
          key: ValueKey(widget.flybisPost.postContents![i].contentUrl),
          url: widget.flybisPost.postContents![i].contentUrl,
          blurHash: widget.flybisPost.postContents![i].blurHash,
          onDoubleTap: handleLikes,
        );
      } else {
        content = video_widget.VideoWidget(
          type: video_widget.VideoSourceType.hls,
          source: widget.flybisPost.postContents![i].contentUrl,
          title: widget.flybisPost.postTitle!.length > 0
              ? widget.flybisPost.postTitle
              : widget.flybisPost.postId,
          author: _flybisUser!.displayName,
          imageUrl: widget.flybisPost.postContents![i].contentThumbnail,
          onDoubleTap: handleLikes,
        );
      }

      contents.add(content);
    }

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        contents.length > 1
            ? Column(
                children: <Widget>[
                  carousel_slider.CarouselSlider(
                    carouselController: _carouselController,
                    options: carousel_slider.CarouselOptions(
                      height: contentHeight,
                      viewportFraction: 1.0,
                      autoPlay: false,
                      pageSnapping: false,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: false,
                      scrollPhysics: BouncingScrollPhysics(),
                      aspectRatio: widget.flybisPost
                          .postContents![_contentIndex].contentAspectRatio!,
                      onPageChanged: (int index, var reason) {
                        if (mounted) {
                          setState(() {
                            _contentIndex = index;
                          });
                        }
                      },
                    ),
                    items: contents,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 15),
                    child: DotsIndicator(
                      dotsCount: contents.length,
                      position: _contentIndex.toDouble(),
                      decorator: DotsDecorator(
                        color: Colors.grey,
                        activeColor:
                            pageColors[Random().nextInt(pageColors.length)],
                      ),
                      onTap: (double contentPage) {
                        _carouselController.animateToPage(contentPage.round());
                      },
                    ),
                  )
                ],
              )
            : contents[0],
        iconShow
            ? likeOrDislikeAnimation(iconData, iconColor, iconSize)
            : Padding(padding: EdgeInsets.zero),
      ],
    );
  }

  Widget footer(BuildContext context) {
    const double kHorizontalPadding = 15;
    const double kVerticalPadding = 12.5;

    double footerWidth = (!kIsWeb || MediaQuery.of(context).size.width <= 720)
        ? MediaQuery.of(context).size.width
        : widthWeb(context);

    return Container(
      width: footerWidth,
      child: Column(
        children: <Widget>[
          widget.flybisPost.postDescription.length > 0
              ? Container(
                  width: footerWidth,
                  padding: EdgeInsets.only(
                    left: kHorizontalPadding,
                    top: kVerticalPadding,
                    right: kHorizontalPadding,
                    bottom: kVerticalPadding,
                  ),
                  child: Container(
                    child: DetectableText(
                      text: widget.flybisPost.postDescription,
                      detectionRegExp: hashTagAtSignUrlRegExp,
                      detectedStyle:
                          TextStyle(fontSize: 15, color: Colors.blue),
                      basicStyle: TextStyle(fontSize: 15),
                      onTap: (text) {
                        onTapUsernameHashtagText(text, widget.pageColor);
                      },
                    ),
                  ),
                )
              : Padding(
                  padding: EdgeInsets.only(
                    top: kVerticalPadding,
                    bottom: kVerticalPadding,
                  ),
                ),
          Container(
            padding: EdgeInsets.only(bottom: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(left: kHorizontalPadding)),
                likeOrDislike(type: 'likes', onTap: handleLike),
                Padding(padding: EdgeInsets.only(right: 5)),
                likeOrDislike(type: 'dislikes', onTap: handleDislike),
                Spacer(),
                streamTimestamp(),
                Spacer(),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => showPostComment(
                      widget.flybisPost.userId,
                      widget.flybisPost.postId,
                      widget.pageColor,
                    ),
                    child: Icon(
                      Icons.message,
                      size: 35,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                ),
                Padding(padding: EdgeInsets.only(right: kHorizontalPadding)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget streamTimestamp() {
    final endTimestamp = FlybisPost.checkTimestamp(
      widget.flybisPost.timestampDuration,
      widget.flybisPost.timestampPopularity,
    );

    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1), (i) => i),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

        Duration remaining =
            Duration(milliseconds: endTimestamp - nowTimestamp);

        DateFormat minutesAndSecondsFormat = DateFormat('mm:ss');
        String minutesAndSecondsString = minutesAndSecondsFormat.format(
          DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds),
        );
        final minutesAndSecondsArray = minutesAndSecondsString.split(':');

        final hoursFormat = (remaining.inHours - (24 * remaining.inDays));

        String daysString =
            remaining.inDays > 0 ? remaining.inDays.toString() + 'D:' : '';
        String hoursString =
            hoursFormat > 0 ? hoursFormat.toString() + 'H:' : '';
        String minutesString =
            remaining.inMinutes > 0 ? minutesAndSecondsArray[0] + 'M:' : '';
        String secondsString =
            remaining.inSeconds > 0 ? minutesAndSecondsArray[1] + 'S' : '';

        String timestampString = remaining.inSeconds > 0
            ? daysString + hoursString + minutesString + secondsString
            : 'EXPIRADO';

        return Container(
          alignment: Alignment.center,
          child: Text(
            timestampString,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget likeOrDislike({
    String type = 'likes',
    required Function onTap,
  }) {
    return StreamBuilder(
      stream: PostService().streamLikeDislike(
        widget.flybisPost.userId,
        widget.flybisPost.postId,
        type,
        flybisUserOwner!.uid,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<FlybisDocument> snapshot,
      ) {
        Color? defaultColor = Theme.of(context).iconTheme.color;
        Color activeColor = type == 'likes' ? Colors.green : Colors.red;
        IconData icon = type == 'likes' ? Icons.thumb_up : Icons.thumb_down;

        int count = type == 'likes'
            ? widget.flybisPost.likesCount
            : widget.flybisPost.dislikesCount;
        bool exists = snapshot.hasData;

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                iconShow && exists
                    ? likeOrDislikeAnimation(icon, activeColor, 35.0)
                    : Icon(
                        icon,
                        color: exists ? activeColor : defaultColor,
                        size: 35.0,
                      ),
                Padding(padding: EdgeInsets.only(right: 5)),
                Text(
                  format.formatCompactNumber(
                    exists && count <= 0 ? 1 : count,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget likeOrDislikeAnimation(
    IconData? icon,
    Color? color,
    double size,
  ) {
    return animator.Animator(
      duration: Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      cycles: 0,
      builder: (context, anim, child) => Transform.scale(
        scale: anim.value as double,
        child: Icon(
          icon,
          color: color,
          size: size,
        ),
      ),
    );
  }

  Widget buildList() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          header(context),
          content(context),
          footer(context),
        ],
      ),
    );
  }

  Widget buildGrid() {
    Widget image;

    switch (widget.flybisPost.postContents![0].contentType) {
      case 'video':
        image = utils_widget.UtilsWidget().adaptiveImage(
          context,
          widget.flybisPost.postContents![0].contentThumbnail,
          widget.flybisPost.postContents![0].blurHash!,
        );
        break;
      default:
        image = utils_widget.UtilsWidget().adaptiveImage(
          context,
          widget.flybisPost.postContents![0].contentUrl,
          widget.flybisPost.postContents![0].blurHash!,
        );
        break;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        /*onTap: () => showPost(
          widget.flybisPost.userId,
          widget.flybisPost.postId,
          widget.pageColor,
        ),*/
        child: OpenContainer(
          closedBuilder: (BuildContext context, Function() action) {
            return GridTile(child: image);
          },
          openBuilder: (BuildContext context, Function() action) {
            return post_view.PostView(
              flybisPost: widget.flybisPost,
              pageColor: widget.pageColor,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (widget.postWidgetType == PostWidgetType.LIST) {
          return buildList();
        } else {
          return buildGrid();
        }
      },
    );
  }
}

void showPost(
  String userId,
  String postId,
  Color pageColor,
) {
  Get.to(
    post_view.PostView(
      userId: userId,
      postId: postId,
      pageColor: pageColor,
    ),
  );
}

void showPostComment(
  String? userId,
  String? postId,
  Color? pageColor,
) {
  Get.to(
    comment_view.CommentView(
      userId: userId,
      postId: postId,
      commentType: comment_view.CommentType.POSTS,
      pageColor: pageColor,
    ),
  );
}
