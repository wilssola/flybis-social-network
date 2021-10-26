// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/comment_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class CommentService {
  CommentService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Future<void> setComment(
    String? postId,
    FlybisComment flybisComment,
  ) async {
    await _db.set(
      documentPath: DatabasePath.comment(
        flybisComment.userId,
        flybisComment.commentType,
        postId,
        flybisComment.commentId,
      ),
      data: flybisComment.toMap(),
    );
  }

  Stream<List<FlybisComment>>? streamComments(
    String? userId,
    String? commentType,
    String? postId,
    int limit,
  ) =>
      _db.streamCollection(
        collectionPath: DatabasePath.comments(userId, commentType, postId),
        builder: (data, documentId) => FlybisComment.fromMap(data!, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15 + limit),
      );
}
