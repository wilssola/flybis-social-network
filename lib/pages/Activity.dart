import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

// flybis
import "package:flybis/models/Feed.dart";
import "package:flybis/pages/Home.dart";
import "package:flybis/pages/Profile.dart";
import "package:flybis/pages/ViewPost.dart";
import "package:flybis/widgets/Utils.dart";
import "package:flybis/widgets/Header.dart";
import "package:flybis/widgets/Progress.dart";

import "package:flybis/plugins/image_network/image_network.dart";
// flybis - End

import "package:flybis/plugins/timeago.dart";

class Activity extends StatefulWidget {
  final Color pageColor;
  final scaffoldKey;

  Activity({this.pageColor, this.scaffoldKey});

  @override
  ActivityState createState() => ActivityState();
}

class ActivityState extends State<Activity> {
  bool isLoad = false;

  Widget streamFeed() {
    return StreamBuilder(
      stream: activityFeedRef
          .document(currentUser.id)
          .collection("feedItems")
          .orderBy("timestamp", descending: true)
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
          return circularProgress(
            color: widget.pageColor,
          );
        } else {
          if (snapshot.data.documents.length == 0) {
            return infoCenterText("Nenhuma notificação encontrada");
          }

          List<ActivityItem> feedItems = [];
          snapshot.data.documents.forEach((doc) {
            feedItems.add(ActivityItem(feed: Feed.fromDocument(doc)));
          });

          return ListView.builder(
            itemCount: feedItems.length,
            itemBuilder: (context, index) {
              return feedItems[index];
            },
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(
        context,
        titleText: "Notificações",
        pageColor: widget.pageColor,
        scaffoldKey: widget.scaffoldKey,
      ),
      body: streamFeed(),
    );
  }
}

Widget mediaPreview;
String activityItemText;

class ActivityItem extends StatelessWidget {
  final Feed feed;
  final Widget child;

  ActivityItem({this.feed, this.child});

  showPost(context, {String postId, String profileId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: postId,
          userId: profileId,
        ),
      ),
    );
  }

  configureMediaPreview(context) {
    if (feed.type == "like" || feed.type == "comment") {
      mediaPreview = GestureDetector(
        onTap: () => showPost(
          context,
          postId: feed.postId,
          profileId: feed.userId,
        ),
        child: Container(
          width: 50.0,
          height: 50.0,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: ImageNetwork.cachedNetworkImageProvider(
                    feed.mediaUrl != null ? feed.mediaUrl : "",
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      mediaPreview = Text("");
    }

    if (feed.type == "like") {
      activityItemText = "liked your post";
    } else if (feed.type == "follow") {
      activityItemText = "is following you";
    } else if (feed.type == "comment") {
      activityItemText = "replied ${feed.commentData}";
    } else {
      activityItemText = "Error: Unknown type ${feed.type}";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (feed != null && child != null) {
      return null;
    }

    if (child == null) {
      configureMediaPreview(context);

      return Padding(
        padding: EdgeInsets.only(bottom: 2.0),
        child: Container(
          color: Colors.white,
          child: ListTile(
            title: GestureDetector(
              onTap: () => showProfile(
                context,
                profileId: feed.userId,
              ),
              child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(
                        text: "@" + feed.username,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      TextSpan(
                        text: " $activityItemText",
                      ),
                    ]),
              ),
            ),
            leading: CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                feed.userProfileImg != null ? feed.userProfileImg : "",
              ),
            ),
            subtitle: Text(
              timeUntil(feed.timestamp.toDate(),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            trailing: mediaPreview,
          ),
        ),
      );
    } else {
      return child;
    }
  }
}

showProfile(BuildContext context, {@required String profileId, Color pageColor = Colors.black}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => Profile(
        profileId: profileId,
        pageColor: pageColor,
      ),
    ),
  );
}
