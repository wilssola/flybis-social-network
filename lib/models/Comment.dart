import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flutter/material.dart';

class Comment extends StatelessWidget {
  final String username;
  final String uid;
  final String photoUrl;
  final String content;
  final Timestamp timestamp;

  Comment({
    this.username,
    this.uid,
    this.photoUrl,
    this.content,
    this.timestamp,
  });

  factory Comment.fromDocument(DocumentSnapshot doc) {
    return Comment(
      username: doc['username'],
      uid: doc['uid'],
      content: doc['content'],
      timestamp: doc['timestamp'],
      photoUrl: doc['photoUrl'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          title: Text(content),
          leading: CircleAvatar(
            backgroundImage: ImageNetwork.cachedNetworkImageProvider(
              photoUrl != null ? photoUrl : "",
            ),
          ),
          subtitle: Text(
            timestamp != null ? timeUntil(timestamp.toDate()) : "",
          ),
        ),
      ],
    );
  }
}
