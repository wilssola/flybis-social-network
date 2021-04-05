// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/document_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class FollowService {
  FollowService();

  final DatabaseService _db = DatabaseService.instance;

  Future<void> setFollower(String userId, String followerId) async =>
      await _db.set(
        documentPath: PathService.follower(userId, followerId),
        data: {},
      );

  Future<void> setFollowing(String userId, String followingId) async =>
      await _db.set(
        documentPath: PathService.following(userId, followingId),
        data: {},
      );

  Future<List<FlybisDocument>> getFollowings(String userId) async =>
      await _db.getCollection(
        collectionPath: PathService.followings(userId),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
      );

  Stream<bool> streamFollowing(String userId, String followingId) =>
      _db.streamDoc(
        documentPath: PathService.following(userId, followingId),
        builder: (data, documentId) => data != null,
      );

  Future<void> deleteFollower(String userId, String followerId) async =>
      await _db.delete(
        documentPath: PathService.follower(userId, followerId),
      );

  Future<void> deleteFollowing(String userId, String followingId) async =>
      await _db.delete(
        documentPath: PathService.following(userId, followingId),
      );

  Future<void> followUser(String userId, String senderId) async {
    await setFollower(userId, senderId);
    await setFollowing(senderId, userId);
  }

  Future<void> unfollowUser(String userId, String senderId) async {
    await deleteFollower(userId, senderId);
    await deleteFollowing(senderId, userId);
  }
}
