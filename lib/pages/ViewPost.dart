import 'package:flutter/material.dart';
import 'package:flybis/widgets/PostWidget.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/models/Post.dart';
import 'package:flybis/pages/Home.dart';
import 'package:flybis/widgets/Progress.dart';

class PostScreen extends StatelessWidget {
  final String userId;
  final String postId;

  PostScreen({
    this.postId,
    this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: postsRef
          .document(userId)
          .collection('userPosts')
          .document(postId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(color: Colors.red);
        }

        if (!snapshot.data.exists) {
          return screen(
            context,
            "Erro",
            Center(
              child: Container(
                child: Text("Post não existente"),
              ),
            ),
          );
        }

        Post post = Post.fromDocument(
          snapshot.data,
        );

        return screen(
          context,
          post.description,
          PostWidget(
            post: post,
            pageColor: Colors.red,
          ),
        );
      },
    );
  }

  Widget screen(BuildContext context, String title, Widget child) {
    return Scaffold(
      appBar: header(
        context,
        titleText: title,
      ),
      body: ListView(
        children: <Widget>[child],
      ),
    );
  }
}
