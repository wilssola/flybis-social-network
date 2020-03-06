import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

import "package:flybis/models/Post.dart";
import "package:flybis/models/User.dart";
import "package:flybis/pages/App.dart";
import "package:flybis/pages/Search.dart";
import "package:flybis/widgets/PostWidget.dart";
import "package:flybis/widgets/Progress.dart";
import "package:flybis/widgets/Header.dart";
import "package:flybis/widgets/Utils.dart";
import "package:flybis/widgets/Ads.dart";

import "package:cloud_firestore/cloud_firestore.dart";
import "package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart";

class Timeline extends StatefulWidget {
  final User currentUser;
  final GlobalKey scaffoldKey;
  final Color pageColor;

  Timeline({this.currentUser, this.scaffoldKey, this.pageColor});

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends State<Timeline>
    with AutomaticKeepAliveClientMixin<Timeline> {
  List<String> followingList = [];
  List<PostWidget> postsList = [];

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    getTimeline();
    streamPosts();
  }

  void streamPosts() {
    timelineRef
        .document(widget.currentUser.uid)
        .collection("createdPosts")
        .orderBy("timestamp", descending: true)
        .snapshots()
        .listen((event) {
      List<PostWidget> posts = [];

      event.documentChanges.forEach((element) {
        if (element.type == DocumentChangeType.added) {
          print("Post Adicionado: " + element.document.documentID);

          timelineRef
              .document(widget.currentUser.uid)
              .collection("timelinePosts")
              .document(element.document.documentID)
              .get()
              .then((value) {
            addPosts(value, posts);
            print("Doc Adicionado: " + value.documentID);
          });
        } else if (element.type == DocumentChangeType.removed) {
          print("Post Deletado: " + element.document.documentID);

          setState(() {
            removePosts(element.document.documentID, this.postsList);
          });
        }
      });

      setState(() {
        this.postsList.addAll(posts);
      });
    });
  }

  Future<void> getTimeline() async {
    setState(() {
      postsList = [];
    });

    await getFollowing();
    await getPosts();

    if (mounted && !loaded) {
      setState(() {
        loaded = true;
      });
    }

    return null;
  }

  Future<void> getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.uid)
        .collection("userFollowing")
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

  Future<void> getPosts() async {
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.uid)
        .collection("timelinePosts")
        .orderBy("timestamp", descending: true)
        .limit(10)
        .getDocuments();

    List<PostWidget> posts = [];

    snapshot.documents.forEach((doc) {
      addPosts(doc, posts);
    });

    setState(() {
      this.postsList = posts;
    });
  }

  void addPosts(DocumentSnapshot doc, List<PostWidget> list) {
    PostWidget post = PostWidget(
      Post.fromDocument(doc),
      PostType.LIST,
      pageColor: widget.pageColor,
    );

    final localValidity = Post.checkValidity(
      doc["timestampDuration"],
      doc["timestampPopularity"],
    );

    final serverValidity = doc["validity"];

    if (localValidity && serverValidity) {
      list.add(post);
    }
  }

  void removePosts(String id, List<PostWidget> list) {
    list.removeWhere((element) => element.post.id == id);
  }

  ListView buildTimeline() {
    return ListView(
      children: <Widget>[
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: postsList.length,
          itemBuilder: (context, index) {
            return postsList[index];
          },
        ),
      ],
    );
  }

  ListView buildUsersToFollow() {
    return ListView(
      children: <Widget>[
        FutureBuilder(
          future: usersRef
              .orderBy("timestamp", descending: true)
              .limit(25)
              .getDocuments(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return listViewContainer(
                  context, circularProgress(color: widget.pageColor));
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

            if (users.length > 0) {
              //bannerToList(users, 5, bannerMedia());
            } else {
              return listViewContainer(
                context,
                infoText("Nenhum usuário encontrado"),
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
  bool get wantKeepAlive => true;

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
      body: loaded
          ? LiquidPullToRefresh(
              onRefresh: getTimeline,
              color: widget.pageColor,
              child:
                  postsList.length > 0 ? buildTimeline() : buildUsersToFollow(),
            )
          : circularProgress(color: widget.pageColor),
    );
  }
}
