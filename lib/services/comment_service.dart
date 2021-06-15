// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/models/comment_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class CommentService {
  CommentService();

  final DatabaseService _db = DatabaseService.instance;

  Future<void> setComment(
    String? postId,
    FlybisComment flybisComment,
  ) async {
    await _db.set(
      documentPath: PathService.comment(
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
        collectionPath: PathService.comments(userId, commentType, postId),
        builder: (data, documentId) => FlybisComment.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15 + limit),
      );
}
