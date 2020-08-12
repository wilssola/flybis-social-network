import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flybis/const.dart';
import 'package:flybis/pages/App/Bell.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:flutter/material.dart';
import 'package:flybis/widgets/Utils.dart';

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
      // User
      uid: doc['uid'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],

      // Comment
      content: doc['content'],
      timestamp: doc['timestamp'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: CircleAvatar(
            backgroundColor: avatarBackground,
            backgroundImage: ImageNetwork.cachedNetworkImageProvider(
              photoUrl != null ? photoUrl : '',
            ),
          ),
          title: GestureDetector(
            onTap: () {
              showProfile(context, profileId: uid);
            },
            child: usernameText(username),
          ),
          subtitle: Text(content),
          trailing: Text(
            timestamp != null ? timeUntil(timestamp.toDate()) : '',
          ),
        ),
      ],
    );
  }
}
