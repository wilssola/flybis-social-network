import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

// Pub.dev
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';

// Flybis
import 'package:flybis/const.dart';
import 'package:flybis/models/Bell.dart';

import 'package:flybis/pages/App.dart';
import 'package:flybis/pages/App/Profile.dart';

import 'package:flybis/services/Admob.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/views/PostView.dart';
import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
// Flybis - End

class BellPage extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color pageColor;

  BellPage({@required this.scaffoldKey, @required this.pageColor});

  @override
  BellState createState() => BellState();
}

class BellState extends State<BellPage>
    with AutomaticKeepAliveClientMixin<BellPage> {
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
    scrollInit();

    super.initState();
  }

  Widget streamFeed() {
    return StreamBuilder(
      stream: activityFeedRef
          .document(currentUser.uid)
          .collection('feedItems')
          .orderBy('timestamp', descending: true)
          .limit(15 + limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(context, color: widget.pageColor);
        }

        if (snapshot.data.documents.length == 0) {
          return infoText('Nenhuma notificação encontrada');
        }

        List<Widget> feedItems = [];
        snapshot.data.documents.forEach((doc) {
          feedItems.add(ActivityItem(
            feed: Bell.fromDocument(doc),
            pageColor: widget.pageColor,
          ));
        });

        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: feedItems.length,
          itemBuilder: (context, index) {
            return feedItems[index];
          },
        );
      },
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
        titleText: 'Notificações',
        pageColor: widget.pageColor,
      ),
      body: Scrollbar(
        isAlwaysShown: kIsWeb,
        child: ListView(
          controller: scrollController,
          children: [
            Admob(
              type: NativeAdmobType.banner,
              height: 100,
              color: widget.pageColor,
            ),
            streamFeed(),
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

Widget mediaPreview;
String activityItemText;

class ActivityItem extends StatelessWidget {
  final Bell feed;
  final Color pageColor;

  ActivityItem({this.feed, this.pageColor});

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
    if (feed.type == 'like' || feed.type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(
          context,
          postId: feed.id,
          profileId: feed.ownerUid,
        ),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: ImageNetwork.cachedNetworkImageProvider(
            feed.content != null ? feed.content : '',
          ),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (feed.type == 'like') {
      activityItemText = 'liked your post';
    } else if (feed.type == 'follow') {
      activityItemText = 'is following you';
    } else if (feed.type == 'comment') {
      activityItemText = 'replied ${feed.data}';
    } else {
      activityItemText = 'Error: Unknown type ${feed.type}';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (feed != null) {
      configureMediaPreview(context);

      return ListTile(
        title: GestureDetector(
          onTap: () =>
              showProfile(context, profileId: feed.uid, pageColor: pageColor),
          child: Row(
            children: <Widget>[
              usernameText(feed.username),
              Container(
                width: MediaQuery.of(context).size.width * 0.35,
                child: Text(
                  ' $activityItemText',
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        leading: CircleAvatar(
          backgroundColor: avatarBackground,
          backgroundImage: ImageNetwork.cachedNetworkImageProvider(
            feed.photoUrl != null ? feed.photoUrl : '',
          ),
        ),
        subtitle: Text(timeUntil(feed.timestamp.toDate())),
        trailing: mediaPreview,
      );
    }

    return Text('');
  }
}

void showProfile(
  BuildContext context, {
  @required String profileId,
  Color pageColor = Colors.black,
}) {
  if (profileId != currentUser.uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(
          profileId: profileId,
          pageColor: pageColor,
        ),
      ),
    );
  }
}
