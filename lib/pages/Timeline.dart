import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flybis/models/Post.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/pages/Home.dart';
import 'package:flybis/pages/Search.dart';
import 'package:flybis/widgets/PostWidget.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/Ads.dart';

class Timeline extends StatefulWidget {
  final User currentUser;
  final GlobalKey scaffoldKey;
  final Color pageColor;

  Timeline({this.currentUser, this.scaffoldKey, this.pageColor});

  @override
  TimelineState createState() => TimelineState();
}

class TimelineState extends State<Timeline> {
  bool isLoad = false;
  List<String> followingList = [];

  @override
  void initState() {
    super.initState();

    getFollowing();
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();

    if (mounted) {
      setState(() {
        followingList = snapshot.documents.map((doc) => doc.documentID).toList();
      });
    }
  }

  buildTimeline() {
    return StreamBuilder(
      stream: timelineRef
          .document(widget.currentUser.id)
          .collection('timelinePosts')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        Future.delayed(Duration(seconds: 1)).then((_) {
          if (mounted) {
            setState(() {
              isLoad = true;
            });
          }
        });

        if (!snapshot.hasData || !isLoad) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.8,
            child: circularProgress(
              color: widget.pageColor,
            ),
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return buildUsersToFollow();
          }

          List<Widget> posts = [];

          snapshot.data.documents.forEach((doc) {
            PostWidget searchResult;

            Post post = Post.fromDocument(doc);
            searchResult = PostWidget(post: post, pageColor: widget.pageColor);

            final manualValidity = Post.checkValidity(
              doc['timestampDuration'],
              doc['timestampPopularity'],
            );

            final validity = doc['validity'];

            if (manualValidity && validity) {
              posts.add(searchResult);
            }
          });

          if (!kIsWeb) {
            bannerToList(
              posts,
              5,
              Ads(AdsType.BANNER_MEDIUM),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return posts[index];
            },
          );
        }
      },
    );
  }

  buildUsersToFollow() {
    return FutureBuilder(
      future:
          usersRef.orderBy('timestamp', descending: true).limit(25).getDocuments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: circularProgress(
              color: widget.pageColor,
            ),
          );
        }

        List<Widget> userResults = [];
        snapshot.data.documents.forEach((doc) {
          User user = User.fromDocument(doc);

          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingList.contains(user.id);

          if (isAuthUser) {
            return;
          } else if (isFollowingUser) {
            return;
          } else {
            UserResult userResult = UserResult(user: user);
            userResults.add(userResult);
          }
        });

        if (!kIsWeb) {
          if (userResults.length > 0) {
            userResults.insert(
              0,
              UserResult(
                child: bannerMedia(),
              ),
            );
          } else {
            return infoCenterText("Nenhum usuário encontrado");
          }
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: userResults.length,
          itemBuilder: (context, index) {
            return userResults[index];
          },
        );
      },
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: header(
        context,
        isAppTitle: true,
        scaffoldKey: widget.scaffoldKey,
        pageColor: widget.pageColor,
      ),
      body: ListView(
        children: <Widget>[
          buildTimeline(),
        ],
      ),
    );
  }
}
