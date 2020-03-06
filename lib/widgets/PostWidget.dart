import 'dart:async';

//
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// flybis
import 'package:flybis/models/Post.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/pages/App.dart';
import 'package:flybis/pages/Comments.dart';
import 'package:flybis/pages/Activity.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/widgets/VideoWidget.dart';
import 'package:flybis/widgets/ViewPhoto.dart';

import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/widgets/ViewPost.dart';
// flybis - End

import 'package:intl/intl.dart';
import 'package:animator/animator.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flybis/plugins/format.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart';

import '../const.dart';
import 'ImageWidget.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final Color pageColor;
  final PostType type;

  PostWidget(this.post, this.type, {this.pageColor = Colors.black});

  @override
  PostWidgetState createState() => PostWidgetState();
}

enum PostType { LIST, GRID }

class PostWidgetState extends State<PostWidget> {
  String currentUserId = currentUser?.uid;

  int likeCount = 0;
  int dislikeCount = 0;
  bool isLiked = false;
  bool isDisliked = false;

  Map likes;
  Map dislikes;
  bool showIcon = false;

  IconData iconData;
  Color iconColor;

  @override
  void initState() {
    super.initState();
    likes = widget.post.likes;
    dislikes = widget.post.dislikes;

    likeCount = widget.post.getLikeOrDislikeCount(widget.post.likes);
    dislikeCount = widget.post.getLikeOrDislikeCount(widget.post.dislikes);

    isLiked = likes[currentUserId] == true;
    isDisliked = dislikes[currentUserId] == true;
  }

  TextStyle countStyle() {
    return TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }

  checkLikeOrDislike(String userId) async {
    bool localIsLiked = likes[userId] == true;
    bool localIsDisliked = dislikes[userId] == true;

    if (localIsLiked != isLiked || localIsDisliked != isDisliked) {
      if (mounted) {
        setState(() {
          isLiked = likes[userId] == true;
          isDisliked = dislikes[userId] == true;
        });
      }
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    bool _isDisliked = dislikes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(widget.post.uid)
          .collection('userPosts')
          .document(widget.post.id)
          .updateData(
        {
          'likes.$currentUserId': false,
        },
      );

      if (mounted) {
        setState(() {
          likeCount--;
          isLiked = false;
          likes[currentUserId] = false;
        });
      }

      removeLikeToActivityFeed();
    } else if (!_isLiked && !_isDisliked) {
      postsRef
          .document(widget.post.uid)
          .collection('userPosts')
          .document(widget.post.id)
          .updateData({
        'likes.$currentUserId': true,
      });

      addLikeToActivityFeed();

      if (mounted) {
        setState(() {
          likeCount++;
          isLiked = true;
          iconColor = Colors.green;
          iconData = FeatherIcons.thumbsUp;
          showIcon = true;
          likes[currentUserId] = true;
        });
      }

      Timer(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            showIcon = false;
          });
        }
      });
    }
  }

  handleLikes() {
    if (!isLiked && !isDisliked) {
      handleLikePost();
    } else if (isLiked && !isDisliked) {
      handleLikePost();
      handleDisLikePost();
    } else if (!isLiked && isDisliked) {
      handleDisLikePost();
    }
  }

  handleDisLikePost() async {
    bool _isLiked = likes[currentUserId] == true;
    bool _isDisliked = dislikes[currentUserId] == true;

    if (_isDisliked) {
      postsRef
          .document(widget.post.uid)
          .collection('userPosts')
          .document(widget.post.id)
          .updateData({
        'dislikes.$currentUserId': false,
      });

      if (mounted) {
        setState(() {
          dislikeCount--;
          isDisliked = false;
          dislikes[currentUserId] = false;
        });
      }

      // removeLikeToActivityFeed();
    } else if (!_isDisliked && !_isLiked) {
      postsRef
          .document(widget.post.uid)
          .collection('userPosts')
          .document(widget.post.id)
          .updateData({
        'dislikes.$currentUserId': true,
      });

      // addLikeToActivityFeed();
      if (mounted) {
        setState(() {
          dislikeCount++;
          isDisliked = true;
          iconColor = Colors.red;
          iconData = FeatherIcons.thumbsDown;
          showIcon = true;
          dislikes[currentUserId] = true;
        });
      }
      Timer(Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            showIcon = false;
          });
        }
      });
    }
  }

  addLikeToActivityFeed() {
    bool isNotPostOwner = (currentUserId != widget.post.uid);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.uid)
          .collection('feedItems')
          .document(widget.post.id)
          .setData({
        "type": 'like',
        "username": currentUser.username,
        "userId": currentUser.uid,
        "photoUrl": currentUser.photoUrl,
        "id": widget.post.id,
        "contentUrl": widget.post.contentUrl,
        "timestamp": FieldValue.serverTimestamp()
      });
    }
  }

  removeLikeToActivityFeed() {
    bool isNotPostOwner = (currentUserId != widget.post.uid);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.uid)
          .collection('feedItems')
          .document(widget.post.id)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    }
  }

  buildPostHeader() {
    const double kHeaderHeight = 80;

    return FutureBuilder(
      future: usersRef.document(widget.post.uid).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: kHeaderHeight,
            child: circularProgress(),
          );
        }

        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == widget.post.uid;

        return Container(
          height: kHeaderHeight,
          width:
              !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                user.photoUrl != null ? user.photoUrl : "",
              ),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(context,
                  profileId: widget.post.uid, pageColor: widget.pageColor),
              child: Text(
                '@' + user.username,
                style:
                    TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text(widget.post.location),
            trailing: GestureDetector(
              onTap: () => handleDeletePost(context, isPostOwner),
              child: Icon(FeatherIcons.moreVertical, color: Colors.black),
            ),
          ),
        );
      },
    );
  }

  handleDeletePost(BuildContext parentContext, bool isPostOwner) {
    return showDialog(
      context: parentContext,
      builder: (context) => SimpleDialog(
        title: Text("Opções do Post"),
        children: <Widget>[
          isPostOwner
              ? SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
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

  // To delete a post, uid and currentUserId must be equal.
  deletePost() async {
    // Delete uploaded content from the post.
    StorageReference ref = await storageUrlRef(widget.post.contentUrl);
    ref.delete();
    //storageRef.child(widget.post.uid + '/posts/${widget.post.contentType}s/${widget.post.id}.jpg').delete();

    // Delete post itself.
    postsRef
        .document(widget.post.uid)
        .collection('userPosts')
        .document(widget.post.id)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Delete all activity field notifications.
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(widget.post.uid)
        .collection('feedItems')
        .where('id', isEqualTo: widget.post.id)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Delete all comments.
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(widget.post.id)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  buildPostContent(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        widget.post.contentType == "image"
            ? ImageWidget(
                url: widget.post.contentUrl,
                onDoubleTap: handleLikes,
              )
            : VideoWidget(
                url: widget.post.contentUrl,
                onDoubleTap: handleLikes,
              ),
        showIcon
            ? likeAnimation(
                iconData,
                iconColor,
                !kIsWeb
                    ? MediaQuery.of(context).size.width * 0.25
                    : MediaQuery.of(context).size.width * 0.125,
              )
            : Padding(padding: EdgeInsets.zero),
      ],
    );
  }

  Animator likeAnimation(icon, color, size) {
    return Animator(
      duration: Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.elasticOut,
      cycles: 0,
      builder: (anim) => Transform.scale(
        scale: anim.value,
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }

  buildPostFooter(BuildContext context) {
    return Container(
      width: !kIsWeb ? MediaQuery.of(context).size.width : widthWeb(context),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                  top: 50.0,
                  bottom: 25.0,
                  left: 15.0,
                ),
              ),
              GestureDetector(
                onTap: handleLikePost,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    showIcon && isLiked
                        ? likeAnimation(
                            FeatherIcons.thumbsUp, Colors.green, 35.0)
                        : Icon(
                            FeatherIcons.thumbsUp,
                            color: isLiked ? Colors.green : Colors.black,
                            size: 35.0,
                          ),
                    Padding(
                        padding: EdgeInsets.only(
                      right: 5,
                    )),
                    Text(formatCompactNumber(likeCount)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 5)),
              GestureDetector(
                onTap: handleDisLikePost,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    showIcon && isDisliked
                        ? likeAnimation(
                            FeatherIcons.thumbsDown, Colors.red, 35.0)
                        : Icon(
                            FeatherIcons.thumbsDown,
                            color: isDisliked ? Colors.red : Colors.black,
                            size: 35.0,
                          ),
                    Padding(padding: EdgeInsets.only(right: 5)),
                    Text(formatCompactNumber(dislikeCount)),
                  ],
                ),
              ),
              Spacer(),
              streamTimestamp(),
              Spacer(),
              GestureDetector(
                onTap: () => showComments(
                  context,
                  id: widget.post.id,
                  uid: widget.post.uid,
                  contentUrl: widget.post.contentUrl,
                ),
                child: Icon(
                  FeatherIcons.messageCircle,
                  size: 35.0,
                  color: Colors.black,
                ),
              ),
              Padding(padding: EdgeInsets.only(right: 15.0)),
            ],
            mainAxisAlignment: MainAxisAlignment.start,
          ),
          widget.post.description.length > 0
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.only(left: 15.0)),
                    Container(
                      child: Row(
                        children: <Widget>[
                          Text(
                            widget.post.description != ""
                                ? "@${widget.post.username}"
                                : "",
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Padding(padding: EdgeInsets.only(right: 5)),
                          Text(
                            widget.post.description != ""
                                ? widget.post.description
                                : "",
                            style: TextStyle(color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(right: 15.0)),
                  ],
                )
              : Padding(padding: EdgeInsets.zero),
        ],
      ),
    );
  }

  Widget streamTimestamp() {
    final endTimestamp = Post.checkTimestamp(
      widget.post.timestampDuration,
      widget.post.timestampPopularity,
    );

    return StreamBuilder(
      stream: Stream.periodic(Duration(seconds: 1), (i) => i),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

        Duration remaining =
            Duration(milliseconds: endTimestamp - nowTimestamp);

        DateFormat minutesAndSecondsFormat = DateFormat("mm:ss");
        String minutesAndSecondsString = minutesAndSecondsFormat.format(
            DateTime.fromMillisecondsSinceEpoch(remaining.inMilliseconds));
        final minutesAndSecondsArray = minutesAndSecondsString.split(":");

        final hoursFormat = (remaining.inHours - (24 * remaining.inDays));

        String daysString =
            remaining.inDays > 0 ? remaining.inDays.toString() + "D:" : "";
        String hoursString =
            hoursFormat > 0 ? hoursFormat.toString() + "H:" : "";
        String minutesString =
            remaining.inMinutes > 0 ? minutesAndSecondsArray[0] + "M:" : "";
        String secondsString =
            remaining.inSeconds > 0 ? minutesAndSecondsArray[1] + "S" : "";

        String timestampString = remaining.inSeconds > 0
            ? daysString + hoursString + minutesString + secondsString
            : "EXPIRADO";

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

  void showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: widget.post.id,
          userId: widget.post.uid,
        ),
      ),
    );
  }

  void showComments(
    BuildContext context, {
    String id,
    String uid,
    String contentUrl,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return Comments(
            postId: id,
            postOwnerId: uid,
            postcontentUrl: contentUrl,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.type == PostType.LIST) {
      return Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            buildPostHeader(),
            buildPostContent(context),
            buildPostFooter(context),
          ],
        ),
      );
    }

    return GridTile(
      child: GestureDetector(
        onTap: () => showPost(context),
        child: widget.post.contentType == "image"
            ? adaptiveImage(context, widget.post.contentUrl)
            : Text("Vídeo"),
      ),
    );
  }
}
