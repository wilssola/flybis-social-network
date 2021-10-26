// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class FriendService {
  FriendService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Future<void> setFriend(String? userId, String? friendId) async =>
      await _db.set(
        documentPath: DatabasePath.friend(userId, friendId),
        data: {},
      );

  Future<void> setFriendRequest(String? userId, String? friendId) async =>
      await _db.set(
        documentPath: DatabasePath.friendRequest(userId, friendId),
        data: {},
      );

  Future<void> deleteFriend(String? userId, String? friendId) async =>
      await _db.delete(
        documentPath: DatabasePath.follower(userId, friendId),
      );

  Future<void> deleteFriendRequest(String? userId, String? friendId) async =>
      await _db.delete(
        documentPath: DatabasePath.following(userId, friendId),
      );

  Stream<bool>? streamFriend(String? userId, String? friendId) => _db.streamDoc(
        documentPath: DatabasePath.friend(userId, friendId),
        builder: (data, documentId) => data != null,
      );

  Stream<bool>? streamFriendRequest(String? userId, String? friendId) =>
      _db.streamDoc(
        documentPath: DatabasePath.friendRequest(userId, friendId),
        builder: (data, documentId) => data != null,
      );

  Future<void> friendUser(String? userId, String? senderId) async {
    await setFriend(userId, senderId);
    await setFriend(senderId, userId);
  }

  Future<void> unfriendUser(String? userId, String? senderId) async {
    await deleteFriend(userId, senderId);
    await deleteFriend(senderId, userId);
  }

  Future<void> friendRequestUser(String? userId, String? senderId) async {
    await setFriendRequest(userId, senderId);
  }

  Future<void> friendUnrequestUser(String? userId, String? senderId) async {
    await deleteFriendRequest(userId, senderId);
    await deleteFriendRequest(senderId, userId);
  }
}
