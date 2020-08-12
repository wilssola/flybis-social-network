import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';

// Flybis
import 'package:flybis/const.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:flybis/pages/App.dart';

import 'package:flybis/models/Comment.dart';
import 'package:flybis/services/Admob.dart';

import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Progress.dart';
// Flybis - End

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentView extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postcontentUrl;
  final Color pageColor;

  CommentView({
    this.postId,
    this.postcontentUrl,
    this.postOwnerId,
    this.pageColor,
  });

  @override
  CommentState createState() => CommentState(
        postId: this.postId,
        postOwnerId: this.postOwnerId,
        postcontentUrl: this.postcontentUrl,
        pageColor: this.pageColor,
      );
}

class CommentState extends State<CommentView> {
  final String postId;
  final String postOwnerId;
  final String postcontentUrl;
  final Color pageColor;

  CommentState({
    this.postId,
    this.postcontentUrl,
    this.postOwnerId,
    this.pageColor,
  });

  TextEditingController commentController = TextEditingController();

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
  }

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .limit(15 + limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });

        return Scrollbar(
          isAlwaysShown: kIsWeb,
          child: ListView(
            controller: scrollController,
            children: comments,
          ),
        );
      },
    );
  }

  addComment() {
    if (commentController.text.trim() != '') {
      commentsRef.document(postId).collection('comments').add({
        // User
        'uid': currentUser.uid,
        'username': currentUser.username,
        'photoUrl': currentUser.photoUrl,

        // Comment
        'content': commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      bool isNotCommentOwner = postOwnerId != currentUser.uid;
      if (isNotCommentOwner) {
        activityFeedRef.document(postOwnerId).collection('feedItems').add({
          // User
          'uid': currentUser.uid,
          'username': currentUser.username,
          'photoUrl': currentUser.photoUrl,

          // Comment
          'content': commentController.text,
          'timestamp': FieldValue.serverTimestamp(),

          // Bell
          'type': 'comment',

          // Post
          'postId': postId,
          'postContent': postcontentUrl,
        });
      }

      commentController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Admob(
            type: NativeAdmobType.banner,
            color: widget.pageColor,
          ),
          Expanded(child: buildComments()),
          Container(
            margin: EdgeInsets.all(5),
            child: ListTile(
              title: TextField(
                controller: commentController,
                decoration: InputDecoration(
                  labelText: 'Write a comment',
                  border: InputBorder.none,
                ),
              ),
              trailing: Transform.rotate(
                angle: 45 * pi / 180,
                child: IconButton(
                  color: Colors.black,
                  onPressed: addComment,
                  icon: Icon(FeatherIcons.send),
                ),
              ),
            ),
          ),
        ],
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
