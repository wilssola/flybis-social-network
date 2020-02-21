import 'package:flutter/material.dart';
import 'package:flybis/pages/ViewPost.dart';
import 'package:flybis/widgets/CustomImage.dart';

import 'package:flybis/models/Post.dart';

class PostTile extends StatelessWidget {
  final Post post;
  PostTile(this.post);

  showPost(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PostScreen(
          postId: this.post.postId,
          userId: this.post.ownerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showPost(context),
      child: cachedNetworkImage(post.mediaUrl),
    );
  }
}
