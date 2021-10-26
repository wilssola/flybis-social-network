// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/document_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class FollowService {
  FollowService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Future<void> setFollower(String? userId, String? followerId) async =>
      await _db.set(
        documentPath: DatabasePath.follower(userId, followerId),
        data: {},
      );

  Future<void> setFollowing(String? userId, String? followingId) async =>
      await _db.set(
        documentPath: DatabasePath.following(userId, followingId),
        data: {},
      );

  Future<List<FlybisDocument>?> getFollowings(String? userId) async =>
      await _db.getCollection(
        collectionPath: DatabasePath.followings(userId),
        builder: (data, documentId) => FlybisDocument.fromMap(data, documentId),
      );

  Stream<bool>? streamFollowing(String? userId, String? followingId) =>
      _db.streamDoc(
        documentPath: DatabasePath.following(userId, followingId),
        builder: (data, documentId) => data != null,
      );

  Future<void> deleteFollower(String? userId, String? followerId) async =>
      await _db.delete(
        documentPath: DatabasePath.follower(userId, followerId),
      );

  Future<void> deleteFollowing(String? userId, String? followingId) async =>
      await _db.delete(
        documentPath: DatabasePath.following(userId, followingId),
      );

  Future<void> followUser(String? userId, String? senderId) async {
    await setFollower(userId, senderId);
    await setFollowing(senderId, userId);
  }

  Future<void> unfollowUser(String? userId, String? senderId) async {
    await deleteFollower(userId, senderId);
    await deleteFollowing(senderId, userId);
  }
}
