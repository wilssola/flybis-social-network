import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// flybis
import 'package:flybis/models/Post.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/pages/Home.dart';
import 'package:flybis/pages/Comments.dart';
import 'package:flybis/pages/Activity.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/CustomImage.dart';
import 'package:flybis/widgets/ViewPhoto.dart';

import 'package:flybis/plugins/image_network/image_network.dart';
// flybis - End

import 'package:intl/intl.dart';
import 'package:animator/animator.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:flybis/plugins/format.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final Color pageColor;

  final Widget child;

  PostWidget({this.post, this.child, this.pageColor});

  @override
  _PostWidgetState createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  String currentUserId = currentUser?.id;

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

    if (widget.child == null) {
      likes = widget.post.likes;
      dislikes = widget.post.dislikes;

      likeCount = widget.post.getLikeOrDislikeCount(widget.post.likes);
      dislikeCount = widget.post.getLikeOrDislikeCount(widget.post.dislikes);

      isLiked = likes[currentUserId] == true;
      isDisliked = dislikes[currentUserId] == true;
    }
  }

  TextStyle countStyle() {
    return TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
  }

  checkLikeOrDislike(String userId) async {
    if (mounted) {
      setState(() {
        isLiked = likes[userId] == true;
        isDisliked = dislikes[userId] == true;
      });
    }
  }

  handleLikePost() {
    bool _isLiked = likes[currentUserId] == true;
    bool _isDisliked = dislikes[currentUserId] == true;

    if (_isLiked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': false,
      });

      if (mounted) {
        setState(() {
          likeCount -= 1;
          isLiked = false;
          likes[currentUserId] = false;
        });
      }

      removeLikeToActivityFeed();
    } else if (!_isLiked && !_isDisliked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'likes.$currentUserId': true,
      });

      addLikeToActivityFeed();

      if (mounted) {
        setState(() {
          likeCount += 1;
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
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'dislikes.$currentUserId': false,
      });

      if (mounted) {
        setState(() {
          dislikeCount -= 1;
          isDisliked = false;
          dislikes[currentUserId] = false;
        });
      }

      // removeLikeToActivityFeed();
    } else if (!_isDisliked && !_isLiked) {
      postsRef
          .document(widget.post.ownerId)
          .collection('userPosts')
          .document(widget.post.postId)
          .updateData({
        'dislikes.$currentUserId': true,
      });

      // addLikeToActivityFeed();
      if (mounted) {
        setState(() {
          dislikeCount += 1;
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
    bool isNotPostOwner = (currentUserId != widget.post.ownerId);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.ownerId)
          .collection('feedItems')
          .document(widget.post.postId)
          .setData({
        "type": 'like',
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": FieldValue.serverTimestamp()
      });
    }
  }

  removeLikeToActivityFeed() {
    bool isNotPostOwner = (currentUserId != widget.post.ownerId);
    if (isNotPostOwner) {
      activityFeedRef
          .document(widget.post.ownerId)
          .collection('feedItems')
          .document(widget.post.postId)
          .get(source: Source.serverAndCache)
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
      future: usersRef
          .document(widget.post.ownerId)
          .get(source: Source.serverAndCache),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: kHeaderHeight,
            child: circularProgress(),
          );
        }

        User user = User.fromDocument(snapshot.data);
        bool isPostOwner = currentUserId == widget.post.ownerId;

        return Container(
          height: kHeaderHeight,
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                user.photoUrl != null ? user.photoUrl : "",
              ),
              backgroundColor: Colors.grey,
            ),
            title: GestureDetector(
              onTap: () => showProfile(context,
                  profileId: widget.post.ownerId, pageColor: widget.pageColor),
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
        title: Text("Remove this post ?"),
        children: <Widget>[
          isPostOwner
              ? SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context);
                    deletePost();
                  },
                  child: Text(
                    'Deletar Post',
                    style: TextStyle(color: Colors.red),
                  ),
                )
              : Text(''),
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(context);
              // deletePost();
            },
            child: Text(
              'Reportar Post',
              style: TextStyle(color: Colors.yellow),
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          )
        ],
      ),
    );
  }

  // To delete a post, ownerId and currentUserId must be equal.
  deletePost() async {
    // Delete post itself.
    postsRef
        .document(widget.post.ownerId)
        .collection('userPosts')
        .document(widget.post.postId)
        .get(source: Source.serverAndCache)
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Delete uploaded image from the post.
    storageUrlRef(widget.post.mediaUrl).then((ref) => ref.delete());
    /*storageRef
        .child(widget.post.ownerId + '/post_${widget.post.postId}.jpg')
        .delete();*/

    // Delete all activity field notifications.
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
        .document(widget.post.ownerId)
        .collection('feedItems')
        .where('postId', isEqualTo: widget.post.postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    // Delete all comments.
    QuerySnapshot commentsSnapshot = await commentsRef
        .document(widget.post.postId)
        .collection('comments')
        .getDocuments();
    commentsSnapshot.documents.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Widget adaptiveImage(url) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        //minWidth: MediaQuery.of(context).size.width,
        //maxHeight: !kIsWeb
        //? double.infinity
        //: MediaQuery.of(context).size.height * 0.5,
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: MediaQuery.of(context).size.width,
        minHeight: MediaQuery.of(context).size.height * 0.5,
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: FittedBox(
        fit: BoxFit.cover,
        child: cachedNetworkImage(url),
      ),
    );
  }

  buildPostImage() {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ViewPhoto(
            url: widget.post.mediaUrl,
            pageColor: widget.pageColor,
          ),
        ),
      ),
      onDoubleTap: handleLikes,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          adaptiveImage(widget.post.mediaUrl),
          showIcon
              ? likeAnimation(
                  iconData, iconColor, MediaQuery.of(context).size.width * 0.25)
              : Text('')
        ],
      ),
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

  buildPostFooter() {
    return Column(
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  showIcon && isLiked
                      ? likeAnimation(FeatherIcons.thumbsUp, Colors.green, 35.0)
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
                      ? likeAnimation(FeatherIcons.thumbsDown, Colors.red, 35.0)
                      : Icon(
                          FeatherIcons.thumbsDown,
                          color: isDisliked ? Colors.red : Colors.black,
                          size: 35.0,
                        ),
                  Padding(
                    padding: EdgeInsets.only(right: 5),
                  ),
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
                postId: widget.post.postId,
                ownerId: widget.post.ownerId,
                mediaUrl: widget.post.mediaUrl,
              ),
              child: Icon(
                FeatherIcons.messageCircle,
                size: 35.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 15.0),
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.start,
        ),
        widget.post.description.length > 0
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Text(
                          widget.post.description != ""
                              ? '@${widget.post.username}'
                              : '',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 5),
                        ),
                        Text(
                          widget.post.description,
                          style: TextStyle(color: Colors.black),
                        )
                      ],
                    ),
                  ),
                ],
              )
            : Padding(padding: EdgeInsets.zero),
      ],
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

  @override
  Widget build(BuildContext context) {
    if (widget.child == null) {
      return Container(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          buildPostHeader(),
          buildPostImage(),
          buildPostFooter(),
        ],
      ));
    } else {
      return widget.child;
    }
  }
}

showComments(
  BuildContext context, {
  String postId,
  String ownerId,
  String mediaUrl,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return Comments(
          postId: postId,
          postOwnerId: ownerId,
          postMediaUrl: mediaUrl,
        );
      },
    ),
  );
}
