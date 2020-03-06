import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'package:flybis/const.dart';

// flybis
import "package:flybis/models/Feed.dart";
import "package:flybis/pages/App.dart";
import "package:flybis/pages/Profile.dart";
import "package:flybis/widgets/Utils.dart";
import "package:flybis/widgets/Header.dart";
import "package:flybis/widgets/Progress.dart";

import "package:flybis/plugins/image_network/image_network.dart";

import "package:flybis/widgets/ViewPost.dart";
// flybis - End

import "package:flybis/plugins/timeago.dart";

class Activity extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color pageColor;

  Activity({
    this.scaffoldKey,
    this.pageColor,
  });

  @override
  ActivityState createState() => ActivityState();
}

class ActivityState extends State<Activity>
    with AutomaticKeepAliveClientMixin<Activity> {
  Widget streamFeed() {
    return StreamBuilder(
      stream: activityFeedRef
          .document(currentUser.uid)
          .collection("feedItems")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(color: widget.pageColor);
        }

        if (snapshot.data.documents.length == 0) {
          return infoText("Nenhuma notificação encontrada");
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
      },
    );
  }

  @override
  get wantKeepAlive => true;

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
    print(postId);
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
        onTap: () => showPost(context,
            postId: feed.id, profileId: currentUser.uid //feed.userId,
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
                    feed.contentUrl != null ? feed.contentUrl : "",
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
      activityItemText = "replied ${feed.data}";
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

      return Container(
        child: ListTile(
          title: GestureDetector(
            onTap: () => showProfile(context, profileId: feed.uid),
            child: Row(
              children: <Widget>[
                usernameText(feed.username),
                Container(
                  width: 200,
                  child: Text(
                    " $activityItemText",
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          leading: CircleAvatar(
            backgroundColor: avatarBackground,
            backgroundImage: ImageNetwork.cachedNetworkImageProvider(
              feed.photoUrl != null ? feed.photoUrl : "",
            ),
          ),
          subtitle: Text(timeUntil(feed.timestamp.toDate())),
          trailing: mediaPreview,
        ),
      );
    } else {
      return child;
    }
  }
}

showProfile(
  BuildContext context, {
  @required String profileId,
  Color pageColor = Colors.black,
}) {
  if (profileId != currentUser.uid) {
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
}
