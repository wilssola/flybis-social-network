// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/document_model.dart';
import 'package:flybis/models/post_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class PostService {
  PostService();

  final DatabaseService _db = DatabaseService.instance;

  Future<void> setPost(
    FlybisPost post,
  ) async {
    post.timestamp = _db.serverTimestamp();

    await _db.set(
      documentPath: PathService.post(post.userId, post.postId),
      data: post.toMap(),
    );
  }

  Future<FlybisPost?> getPost(
    String? userId,
    String? postId,
  ) =>
      _db.get(
        documentPath: PathService.post(userId, postId),
        builder: (data, documentId) => FlybisPost.fromMap(data, documentId),
      );

  Stream<FlybisPost>? streamPost(
    String userId,
    String postId,
  ) =>
      _db.streamDoc(
        documentPath: PathService.post(userId, postId),
        builder: (data, documentId) => FlybisPost.fromMap(data, documentId),
      );

  Stream<List<FlybisPost>>? streamPosts(
    String? userId,
    int limit,
  ) =>
      _db.streamCollection(
        collectionPath: PathService.posts(userId),
        builder: (data, documentId) => FlybisPost.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(10 + limit),
      );

  Future<bool?> getLike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.get(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'likes', sender),
        builder: (data, documentId) => data != null,
      );

  Future<bool?> getDislike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.get(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'dislikes', sender),
        builder: (data, documentId) => data != null,
      );

  Future<void> setLike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.set(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'likes', sender),
        data: {},
      );

  Future<void> setDislike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.set(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'dislikes', sender),
        data: {},
      );

  Future<void> deleteLike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.delete(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'likes', sender),
      );

  Future<void> deleteDislike(
    String? userId,
    String? postId,
    String? sender,
  ) =>
      _db.delete(
        documentPath:
            PathService.postLikeDislike(userId, postId, 'dislikes', sender),
      );

  Stream<List<FlybisDocument>>? streamLikesDislikes(
    String userId,
    String postId,
    String type,
  ) =>
      _db.streamCollection(
        collectionPath: PathService.postLikesDislikes(userId, postId, type),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
      );

  Stream<FlybisDocument>? streamLikeDislike(
    String? userId,
    String? postId,
    String type,
    String? sender,
  ) =>
      _db.streamDoc(
        documentPath: PathService.postLikeDislike(userId, postId, type, sender),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
      );

  Future<void> deletePost(
    String? userId,
    String? postId,
  ) =>
      _db.delete(documentPath: PathService.post(userId, postId));
}
