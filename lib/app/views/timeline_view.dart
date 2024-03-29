// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flybis/app/widgets/ad_widget.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/values/function.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/document_model.dart';
import 'package:flybis/app/data/models/live_model.dart';
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/providers/ad_provider.dart'
    deferred as ad_provider;
import 'package:flybis/app/data/services/follow_service.dart'
    deferred as follow_service;
import 'package:flybis/app/data/services/live_service.dart' as live_service;
import 'package:flybis/app/data/services/user_service.dart'
    deferred as user_service;
import 'package:flybis/app/views/live_host_view.dart'
    deferred as live_host_view;
import 'package:flybis/app/views/search_view.dart' deferred as search_view;
import 'package:flybis/app/widgets/post_widget.dart' deferred as post_widget;
import 'package:flybis/app/widgets/utils_widget.dart' deferred as utils_widget;

import 'package:flybis/app/data/services/timeline_service.dart'
    deferred as timeline_service;
import 'package:flybis/app/views/live_client_view.dart'
    deferred as live_client_view;

Future<bool> loadLibraries() async {
  await user_service.loadLibrary();
  await follow_service.loadLibrary();
  await timeline_service.loadLibrary();
  await ad_provider.loadLibrary();
  await live_host_view.loadLibrary();
  await live_client_view.loadLibrary();
  await search_view.loadLibrary();
  await post_widget.loadLibrary();
  await utils_widget.loadLibrary();

  return true;
}

class TimelineView extends StatefulWidget {
  final String pageId = 'Chat';
  final Color pageColor;
  final bool pageHeader;

  final GlobalKey<ScaffoldState> scaffoldKey;

  const TimelineView({
    required this.pageColor,
    this.pageHeader = false,
    required this.scaffoldKey,
  });

  @override
  _TimelineViewState createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView>
    with AutomaticKeepAliveClientMixin<TimelineView> {
  // Scroll
  bool toUpButton = false;
  bool showToUpButton = false;
  int limit = 0;
  int oldLimit = 0;
  ScrollController? scrollController;

  scrollInit() {
    scrollController = ScrollController();
    scrollController!.addListener(scrollListener);
  }

  scrollListener() {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController!.offset <=
            scrollController!.position.minScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = 0;
      });
    }

    if (kIsWeb && !kScreenLittle(context)) {
      listenScrollToUp();
    }
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController!.jumpTo(1.0);

    setState(() {
      limit = 0;
    });
  }

  listenScrollToUp() {
    if (scrollController!.offset > scrollController!.position.minScrollExtent) {
      setState(() {
        toUpButton = true;
        showToUpButton = true;
      });
    } else {
      hideScrollToUpButton();
    }
  }

  hideScrollToUpButton() {
    setState(() {
      toUpButton = false;
    });

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      setState(() {
        showToUpButton = false;
      });
    });
  }
  // Scroll - End

  List<FlybisLive?> _livesList = [];
  FlybisLive? _liveOwner;

  @override
  void initState() {
    super.initState();

    scrollInit();

    setLivesList([]);

    listenLivesList();
  }

  void setLivesList(List<FlybisLive?> flybisLives) {
    bool hasOwner = false;

    for (var flybisLive in flybisLives) {
      if (flybisLive!.userId == flybisUserOwner!.uid) {
        hasOwner = true;

        flybisLives.remove(flybisLive);
        flybisLives.insert(0, flybisLive);

        if (mounted) {
          setState(() {
            _liveOwner = flybisLive;
          });
        }
      }
    }

    if (mounted) {
      setState(() {
        _livesList = flybisLives;

        if (!hasOwner) {
          _liveOwner =
              live_service.LiveService().createLive(flybisUserOwner!.uid);
          _livesList.insert(0, _liveOwner);
        }
      });
    }
  }

  void listenLivesList() {
    live_service.LiveService()
        .streamLives(5)!
        .listen((List<FlybisLive?> flybisLives) {
      logger.d('listenLivesList: $flybisLives');

      setLivesList(flybisLives);
    });
  }

  Future<void> liveCreate(FlybisLive flybisLive) async {
    await live_service.LiveService()
        .startLive(flybisUserOwner!.uid, flybisLive);

    await handleCameraMicrophoneStorage();

    await Get.to(
      live_host_view.LiveHostView(
        live: flybisLive,
      ),
    );
  }

  Future<void> liveJoin(FlybisLive flybisLive) async {
    await Get.to(
      live_client_view.LiveClientView(
        live: flybisLive,
      ),
    );
  }

  Widget lives() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _livesList.length,
        itemBuilder: (BuildContext context, int index) {
          if (_livesList.isEmpty) {
            return const Text('');
          }

          return liveUser(_livesList[index]!);
        },
      ),
    );
  }

  Widget liveUser(FlybisLive flybisLive) {
    bool isOwner = flybisLive.userId == flybisUserOwner!.uid;

    return FutureBuilder(
      future: user_service.UserService().getUser(flybisLive.userId),
      builder: (BuildContext context, AsyncSnapshot<FlybisUser?> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        FlybisUser flybisUser = snapshot.data!;

        return Container(
          margin: const EdgeInsets.all(5),
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 70,
                width: 70,
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      if (isOwner) {
                        liveCreate(_liveOwner!);
                      } else {
                        liveJoin(flybisLive);
                      }
                    },
                    child: Stack(
                      alignment: const Alignment(0, 0),
                      children: <Widget>[
                        !isOwner
                            ? SizedBox(
                                height: 52.5,
                                width: 52.5,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.indigo,
                                        Colors.blue,
                                        Colors.cyan,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                ),
                              )
                            : const Padding(padding: EdgeInsets.zero),
                        SizedBox(
                          height: 50,
                          width: 50,
                          child: CircleAvatar(
                            backgroundColor: kAvatarBackground,
                            backgroundImage:
                                ImageNetwork.cachedNetworkImageProvider(
                              flybisUser.photoUrl!,
                            ),
                          ),
                        ),
                        isOwner
                            ? Container(
                                height: 50,
                                width: 50,
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    size: 15,
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Container(
                                height: 75,
                                width: 75,
                                alignment: Alignment.bottomCenter,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    Container(
                                      height: 20,
                                      width: 27.5,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(3.5),
                                        ),
                                        gradient: LinearGradient(
                                          colors: [
                                            pageColors[0],
                                            pageColors[5],
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: const Padding(
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          'LIVE',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3.5),
              Text(flybisUser.username != null ? flybisUser.username! : ''),
            ],
          ),
        );
      },
    );
  }

  Widget recommendedUsers() {
    Widget loadingWidget = Container(
      padding: const EdgeInsets.all(10),
      child: utils_widget.UtilsWidget().circularProgress(
        context,
        color: widget.pageColor,
      ),
    );

    Widget hasData = kNotIsWebOrScreenLittle(context)
        ? loadingWidget
        : Card(child: loadingWidget);

    Widget errorWidget = Container(
      padding: const EdgeInsets.all(10),
      child: const Text('404'),
    );

    Widget hasError = kNotIsWebOrScreenLittle(context)
        ? errorWidget
        : Card(child: errorWidget);

    return FutureBuilder(
      future:
          follow_service.FollowService().getFollowings(flybisUserOwner!.uid),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisDocument>?> snapshot,
      ) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return hasData;
        }

        if (snapshot.hasError) {
          return hasError;
        }

        List<String?> followings = snapshot.data!
            .map((FlybisDocument document) => document.documentId)
            .toList();

        return FutureBuilder(
          future: user_service.UserService().getUsersRecommendations(),
          builder: (
            BuildContext context,
            AsyncSnapshot<List<FlybisUser>?> snapshot,
          ) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return hasData;
            }

            if (snapshot.hasError) {
              return hasError;
            }

            List<Widget> users = [];

            for (var flybisUser in snapshot.data!) {
              bool isOwner = flybisUserOwner!.uid == flybisUser.uid;
              bool isFollowing = followings.contains(flybisUser.uid);

              if (!isOwner && !isFollowing) {
                Widget userResult = search_view.UserResult(
                  user: flybisUser,
                  pageColor: widget.pageColor,
                );

                users.add(userResult);
              }
            }

            if (users.isEmpty) {
              Widget infoWidget = utils_widget.UtilsWidget().infoText(
                'timeline_info_users_empty'.tr,
              );

              return ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  kNotIsWebOrScreenLittle(context)
                      ? infoWidget
                      : Card(child: infoWidget),
                ],
              );
            }

            Widget infoWidget = utils_widget.UtilsWidget().infoText(
              'timeline_info_users'.tr,
            );

            return ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                kNotIsWebOrScreenLittle(context)
                    ? infoWidget
                    : Card(child: infoWidget),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: users.length,
                  itemBuilder: (BuildContext context, int index) {
                    return kNotIsWebOrScreenLittle(context)
                        ? users[index]
                        : Card(child: users[index]);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget streamTimeline() {
    return StreamBuilder(
      stream: timeline_service.TimelineService()
          .streamTimeline(flybisUserOwner!.uid, limit),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisPost>> snapshot,
      ) {
        if (!snapshot.hasData &&
            snapshot.connectionState == ConnectionState.waiting) {
          return utils_widget.UtilsWidget().scaffoldCenterCircularProgress(
            context,
            color: widget.pageColor,
          );
        }

        List<Widget> posts = [];

        if (snapshot.hasData) {
          for (var flybisPost in snapshot.data!) {
            Widget postWidget = post_widget.PostWidget(
              key: ValueKey(flybisPost.postId),
              flybisPost: flybisPost,
              postWidgetType: post_widget.PostWidgetType.LIST,
              pageColor: widget.pageColor,
            );

            bool localValidity = FlybisPost.checkValidity(
              flybisPost.timestampDuration,
              flybisPost.timestampPopularity,
            );

            bool serverValidity = flybisPost.postValidity;

            if (localValidity && serverValidity) {
              posts.add(postWidget);
            }
          }
        }

        if (posts.isEmpty) {
          Widget infoWidget = utils_widget.UtilsWidget()
              .infoText('timeline_info_posts_empty'.tr);

          AdWidget adWidget = AdWidget(
            pageId: widget.pageId,
            pageColor: widget.pageColor,
          );

          return Column(
            //shrinkWrap: true,
            //physics: NeverScrollableScrollPhysics(),
            children: [
              !kIsWeb
                  ? lives()
                  : utils_widget.UtilsWidget().webBody(context, child: lives()),
              kNotIsWebOrScreenLittle(context)
                  ? adWidget
                  : utils_widget.UtilsWidget().webBody(
                      context,
                      child: Card(child: adWidget),
                    ),
              kNotIsWebOrScreenLittle(context)
                  ? infoWidget
                  : utils_widget.UtilsWidget().webBody(
                      context,
                      child: Card(child: infoWidget),
                    ),
              !kIsWeb
                  ? recommendedUsers()
                  : utils_widget.UtilsWidget().webBody(
                      context,
                      child: recommendedUsers(),
                    ),
            ],
          );
        }

        Widget adWidget = AdWidget(
          pageId: widget.pageId,
          pageColor: widget.pageColor,
          margin: const EdgeInsets.only(top: 15),
        );

        Widget timelineList = Column(
          //shrinkWrap: true,
          //physics: NeverScrollableScrollPhysics(),
          children: [
            !kIsWeb
                ? lives()
                : utils_widget.UtilsWidget().webBody(context, child: lives()),
            kNotIsWebOrScreenLittle(context) ? adWidget : Card(child: adWidget),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              itemBuilder: (BuildContext context, int index) {
                return kNotIsWebOrScreenLittle(context)
                    ? posts[index]
                    : Card(child: posts[index]);
              },
            ),
          ],
        );

        bool showRight = kIsWeb && MediaQuery.of(context).size.width > 1100;

        return !showRight
            ? !kIsWeb
                ? timelineList
                : utils_widget.UtilsWidget()
                    .webBody(context, child: timelineList)
            : utils_widget.UtilsWidget().webBody(
                context,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: widthWeb(context), child: timelineList),
                    const Spacer(),
                    Container(
                      width: 275,
                      margin: const EdgeInsets.only(top: 100),
                      child: Column(
                        children: [
                          recommendedUsers(),
                        ],
                      ),
                    )
                  ],
                ),
                multiply: 1.5,
              );
      },
    );
  }

  Widget timeline() {
    return ListView(
      controller: scrollController,
      children: <Widget>[
        streamTimeline(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder(
      future: loadLibraries(),
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        return Scaffold(
          appBar: utils_widget.UtilsWidget().header(
            context,
            scaffoldKey: widget.scaffoldKey,
            pageColor: widget.pageColor,
            pageHeader: widget.pageHeader,
          ),
          body: !kIsWeb
              ? timeline()
              : Scrollbar(
                  thumbVisibility: true,
                  showTrackOnHover: true,
                  controller: scrollController,
                  child: timeline(),
                ),
          floatingActionButton: !kNotIsWebOrScreenLittle(context)
              ? utils_widget.UtilsWidget().floatingButtonUp(
                  showToUpButton,
                  toUpButton,
                  Icons.arrow_upward,
                  widget.pageColor,
                  scrollToUp,
                  widget.pageId,
                )
              : null,
        );
      },
    );
  }
}
