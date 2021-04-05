// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/models/post_model.dart';
import 'package:flybis/services/post_service.dart';
import 'package:flybis/widgets/post_widget.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

class PostView extends StatefulWidget {
  final FlybisPost flybisPost;

  final String userId;
  final String postId;

  final Color pageColor;

  PostView({
    this.flybisPost,
    this.userId,
    this.postId,
    this.pageColor = Colors.red,
  });

  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  _PostViewState();

  bool _loaded = false;
  PostWidget _postWidget;

  final PostService postService = PostService();

  @override
  void initState() {
    getPost();

    super.initState();
  }

  Future<void> getPost() async {
    FlybisPost flybisPost;

    if (widget.flybisPost == null) {
      flybisPost = await postService.getPost(widget.userId, widget.postId);
    } else {
      flybisPost = widget.flybisPost;
    }

    PostWidget postWidget = PostWidget(
      key: UniqueKey(),
      flybisPost: flybisPost,
      postWidgetType: PostWidgetType.LIST,
      pageColor: Colors.red,
    );

    if (mounted) {
      setState(() {
        if (!_loaded) {
          _loaded = true;
        }

        if (flybisPost != null) {
          this._postWidget = postWidget;
        }
      });
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: utils_widget.UtilsWidget().header(
        context,
        titleText: _postWidget != null ? _postWidget.flybisPost.postTitle : '',
      ),
      body: _loaded
          ? ListView(
              children: <Widget>[
                _postWidget != null
                    ? _postWidget
                    : utils_widget.UtilsWidget().listViewContainer(
                        context,
                        utils_widget.UtilsWidget().infoText(
                          'Post não existente',
                        ),
                      )
              ],
            )
          : utils_widget.UtilsWidget().circularProgress(
              context,
              color: widget.pageColor,
            ),
    );
  }
}
