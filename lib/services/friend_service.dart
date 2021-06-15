// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class FriendService {
  FriendService();

  final DatabaseService _db = DatabaseService.instance;

  Future<void> setFriend(String? userId, String? friendId) async => await _db.set(
        documentPath: PathService.friend(userId, friendId),
        data: {},
      );

  Future<void> setFriendRequest(String? userId, String? friendId) async =>
      await _db.set(
        documentPath: PathService.friendRequest(userId, friendId),
        data: {},
      );

  Future<void> deleteFriend(String? userId, String? friendId) async =>
      await _db.delete(
        documentPath: PathService.follower(userId, friendId),
      );

  Future<void> deleteFriendRequest(String? userId, String? friendId) async =>
      await _db.delete(
        documentPath: PathService.following(userId, friendId),
      );

  Stream<bool>? streamFriend(String? userId, String? friendId) => _db.streamDoc(
        documentPath: PathService.friend(userId, friendId),
        builder: (data, documentId) => data != null,
      );

  Stream<bool>? streamFriendRequest(String? userId, String? friendId) =>
      _db.streamDoc(
        documentPath: PathService.friendRequest(userId, friendId),
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
