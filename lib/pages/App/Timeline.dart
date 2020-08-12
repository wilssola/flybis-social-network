import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flybis/const.dart';

import 'package:flybis/models/Post.dart';
import 'package:flybis/models/User.dart';

import 'package:flybis/pages/App.dart';
import 'package:flybis/pages/App/Search.dart';

import 'package:flybis/widgets/PostWidget.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/services/Admob.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class TimelinePage extends StatefulWidget {
  final User currentUser;
  final GlobalKey scaffoldKey;
  final Color pageColor;

  TimelinePage({this.currentUser, this.scaffoldKey, this.pageColor});

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends State<TimelinePage>
    with AutomaticKeepAliveClientMixin<TimelinePage> {
  List<String> followingList = [];

  // Scroll
  bool toUpButton = false;
  bool showToUpButton = false;
  int limit = 0;
  int oldLimit = 0;
  ScrollController scrollController;

  scrollInit() {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit = 0;
      });
    }

    listenScrollToUp();
    scrollDebug();
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController.jumpTo(1.0);

    setState(() {
      limit = 0;
    });

    scrollDebug();
  }

  listenScrollToUp() {
    if (scrollController.offset > scrollController.position.minScrollExtent) {
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

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        showToUpButton = false;
      });
    });
  }

  scrollDebug() {
    if (oldLimit != limit && !kReleaseMode) {
      oldLimit = limit;
      toastDebug(limit.toString(), widget.pageColor);
    }
  }
  // Scroll - End

  @override
  void initState() {
    super.initState();

    scrollInit();

    getTimeline();
  }

  Future<void> getTimeline() async {
    await getFollowing();

    return null;
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.uid)
        .collection('userFollowing')
        .getDocuments();

    if (mounted) {
      if (mounted) {
        setState(() {
          this.followingList =
              snapshot.documents.map((doc) => doc.documentID).toList();
        });
      }
    }
  }

  StreamBuilder streamPosts() {
    return StreamBuilder(
      stream: timelineRef
          .document(widget.currentUser.uid)
          .collection('timelinePosts')
          .orderBy('timestamp', descending: true)
          .limit(5 + limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(color: widget.pageColor);
        }

        List<PostWidget> posts = [];

        snapshot.data.documents.forEach((doc) {
          PostWidget post = PostWidget(
            Post.fromDocument(doc),
            PostType.LIST,
            pageColor: widget.pageColor,
          );

          final localValidity = Post.checkValidity(
            doc['timestampDuration'],
            doc['timestampPopularity'],
          );

          final serverValidity = doc['validity'];

          if (localValidity && serverValidity) {
            posts.add(post);
          }
        });

        if (posts.length == 0) {
          return infoText('Nenhum post encontrado');
        }
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return posts[index];
          },
        );
      },
    );
  }

  ListView buildUsersToFollow() {
    return ListView(
      children: <Widget>[
        FutureBuilder(
          future: usersRef
              .orderBy('timestamp', descending: true)
              .limit(15)
              .getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return circularProgress(color: widget.pageColor);
            }

            List<Widget> users = [];

            snapshot.data.documents.forEach((doc) {
              User user = User.fromDocument(doc);

              final bool isAuthUser = currentUser.uid == user.uid;
              final bool isFollowingUser = followingList.contains(user.uid);

              if (isAuthUser) {
                return;
              } else if (isFollowingUser) {
                return;
              } else {
                UserResult userResult = UserResult(user: user);
                users.add(userResult);
              }
            });

            if (users.length <= 0) {
              return listViewContainer(
                context,
                Stack(
                  children: [
                    infoText('Nenhum usuário encontrado'),
                    Admob(
                      type: NativeAdmobType.banner,
                      height: 100,
                      color: widget.pageColor,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: users.length,
              itemBuilder: (context, index) {
                return users[index];
              },
            );
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: header(
        context,
        scaffoldKey: widget.scaffoldKey,
        isAppTitle: true,
        pageColor: widget.pageColor,
      ),
      body: Scrollbar(
        isAlwaysShown: kIsWeb,
        child: ListView(
          controller: scrollController,
          children: <Widget>[
            Admob(
              type: NativeAdmobType.banner,
              color: widget.pageColor,
            ),
            streamPosts(),
            Container(
              height: 75,
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: showToUpButton && toUpButton ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: showToUpButton || toUpButton
            ? FloatingActionButton(
                elevation: 0,
                backgroundColor: widget.pageColor,
                child: Icon(FeatherIcons.arrowUp, color: Colors.white),
                onPressed: scrollToUp,
              )
            : Padding(padding: EdgeInsets.zero),
      ),
    );
  }
}
