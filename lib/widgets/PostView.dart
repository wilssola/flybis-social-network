import 'package:flutter/material.dart';

import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/PostWidget.dart';

import 'package:flybis/pages/App.dart';
import 'package:flybis/models/Post.dart';

import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/Utils.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart";

class PostScreen extends StatefulWidget {
  final String userId;
  final String postId;

  final Color pageColor;

  PostScreen({this.postId, this.userId, this.pageColor = Colors.black});

  @override
  PostScreenState createState() => PostScreenState();
}

class PostScreenState extends State<PostScreen> {
  bool loaded = false;
  PostWidget postWidget;

  @override
  void initState() {
    super.initState();

    getPost();
  }

  Future<void> getPost() async {
    DocumentSnapshot doc = await postsRef
        .document(widget.userId)
        .collection('userPosts')
        .document(widget.postId)
        .get();

    if (mounted) {
      setState(() {
        if(!loaded) {
          loaded = true;
        }

        if (doc.exists) {
          postWidget = PostWidget(
            Post.fromDocument(doc),
            PostType.LIST,
            pageColor: Colors.red,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: postWidget != null ? postWidget.post.description : ""),
      body: loaded
          ? LiquidPullToRefresh(
              onRefresh: getPost,
              child: ListView(
                children: <Widget>[
                  postWidget != null
                      ? postWidget
                      : listViewContainer(
                          context,
                          infoText("Post não existente"),
                        )
                ],
              ),
            )
          : circularProgress(color: widget.pageColor),
    );
  }
}
