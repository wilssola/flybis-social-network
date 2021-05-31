// Dart

// 🎯 Dart imports:
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/models/comment_model.dart';
import 'package:flybis/plugins/timestamp.dart';
import 'package:flybis/widgets/comment_widget.dart' deferred as comment_widget;
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

import 'package:flybis/services/comment_service.dart'
    deferred as comment_service;

Future<bool> loadLibraries() async {
  await comment_service.loadLibrary();
  await comment_widget.loadLibrary();

  return true;
}

enum CommentType { POSTS, LIVES, STORIES }

class CommentView extends StatefulWidget {
  final String userId;
  final String postId;

  final CommentType commentType; // posts, lives, stories

  final Color pageColor;

  CommentView({
    @required this.userId,
    @required this.postId,
    @required this.commentType,
    this.pageColor: Colors.red,
  });

  @override
  _CommentViewState createState() => _CommentViewState();
}

class _CommentViewState extends State<CommentView> {
  _CommentViewState();

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
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController.jumpTo(1.0);

    setState(() {
      limit = 0;
    });
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
  // Scroll - End;

  String commentType;
  TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    scrollInit();

    switch (widget.commentType) {
      case CommentType.POSTS:
        commentType = 'posts';
        break;
      case CommentType.LIVES:
        commentType = 'lives';
        break;
      case CommentType.STORIES:
        commentType = 'stories';
        break;
      default:
        commentType = 'posts';
        break;
    }

    super.initState();
  }

  void addComment() async {
    final String commentContent = commentController.text.trim();

    if (commentContent.length > 0) {
      FlybisComment flybisComment = FlybisComment(
        userId: flybisUserOwner.uid,
        commentId: Uuid().v4(),
        commentContent: commentContent,
        commentType: commentType,
        timestamp: serverTimestamp(),
      );

      await comment_service.CommentService().setComment(
        widget.postId,
        flybisComment,
      );

      commentController.clear();

      scrollController.jumpTo(0);
    }
  }

  Widget streamComments() {
    return StreamBuilder(
      stream: comment_service.CommentService().streamComments(
        widget.userId,
        commentType,
        widget.postId,
        limit,
      ),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisComment>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return utils_widget.UtilsWidget().circularProgress(
            context,
            color: widget.pageColor,
          );
        }

        List<Widget> comments = [];

        snapshot.data.forEach((FlybisComment flybisComment) {
          comments.add(
            comment_widget.CommentWidget(
              flybisComment: flybisComment,
            ),
          );
        });

        Widget listComments = ListView.builder(
          controller: scrollController,
          itemCount: comments.length,
          itemBuilder: (
            BuildContext context,
            int index,
          ) {
            return comments[index];
          },
        );

        return !kIsWeb
            ? listComments
            : Scrollbar(
                isAlwaysShown: true,
                showTrackOnHover: true,
                child: listComments,
              );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (!snapshot.hasData) {
          return Text('');
        }

        return Scaffold(
          appBar:
              utils_widget.UtilsWidget().header(context, titleText: 'Comments'),
          body: Column(
            children: <Widget>[
              Expanded(child: streamComments()),
              Container(
                margin: EdgeInsets.all(5),
                child: ListTile(
                  title: TextField(
                    decoration: InputDecoration(
                      labelText: 'Write a comment',
                      border: InputBorder.none,
                    ),
                    controller: commentController,
                    onSubmitted: (String text) => addComment(),
                  ),
                  trailing: IconButton(
                    color: Colors.black,
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    onPressed: addComment,
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
                    backgroundColor: widget.pageColor,
                    child: Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                    onPressed: scrollToUp,
                  )
                : Padding(padding: EdgeInsets.zero),
          ),
        );
      },
    );
  }
}
