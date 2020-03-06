import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:flybis/pages/App.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Progress.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flybis/models/Comment.dart';

class Comments extends StatefulWidget {
  final String postId;
  final String postOwnerId;
  final String postcontentUrl;

  Comments({this.postId, this.postcontentUrl, this.postOwnerId});

  @override
  CommentsState createState() => CommentsState(
      postId: this.postId,
      postOwnerId: this.postOwnerId,
      postcontentUrl: this.postcontentUrl);
}

class CommentsState extends State<Comments> {
  final String postId;
  final String postOwnerId;
  final String postcontentUrl;
  TextEditingController commentController = TextEditingController();

  CommentsState({this.postId, this.postcontentUrl, this.postOwnerId});

  buildComments() {
    return StreamBuilder(
      stream: commentsRef
          .document(postId)
          .collection('comments')
          .orderBy('timestamp', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }

        List<Comment> comments = [];
        snapshot.data.documents.forEach((doc) {
          comments.add(Comment.fromDocument(doc));
        });

        return ListView(children: comments);
      },
    );
  }

  addComment() {
    commentsRef.document(postId).collection('comments').add({
      'username': currentUser.username,
      'comment': commentController.text,
      'timestamp': FieldValue.serverTimestamp(),
      'photoUrl': currentUser.photoUrl,
      'userId': currentUser.uid
    });
    bool isNotCommentOwner = postOwnerId != currentUser.uid;
    if (isNotCommentOwner) {
      activityFeedRef.document(postOwnerId).collection('feedItems').add({
        'type': 'comment',
        'commentData': commentController.text,
        'timestamp': FieldValue.serverTimestamp(),
        'postId': postId,
        'username': currentUser.username,
        'userId': currentUser.uid,
        'photoUrl': currentUser.photoUrl,
        "contentUrl": postcontentUrl,
      });
    }
    commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: 'Comments'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Write a comment'),
            ),
            trailing: OutlineButton(
              onPressed: addComment,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          )
        ],
      ),
    );
  }
}
