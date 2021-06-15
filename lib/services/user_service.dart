// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/models/user_model.dart';
import 'package:flybis/services/auth_service.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/follow_service.dart';
import 'package:flybis/services/path_service.dart';
import 'package:flybis/services/realtime_service.dart';

class UserService {
  UserService();

  final DatabaseService _db = DatabaseService.instance;
  final RealtimeService _rt = RealtimeService.instance;

  FollowService followService = FollowService();
  Auth authService = Auth();

  StreamSubscription? streamSubscription;

  Future<String?> getUsername(String username) async => await _db.get(
        documentPath: PathService.username(username),
        builder: ((data, documentId) => data != null ? data['uid'] : null) as String Function(Map<String, dynamic>?, String),
      );

  Future<void> setUser(FlybisUser user) async => await _db.set(
        documentPath: PathService.user(user.uid),
        data: user.toMap(),
      );

  Future<void> updateUser(String? userId, FlybisUser user) async => await _db
      .update(documentPath: PathService.user(userId), data: user.toMap());

  Future<FlybisUser?> getUser(String? userId) async => await _db.get(
        documentPath: PathService.user(userId),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
      );

  Stream<FlybisUser>? streamUser(String? userId) => _db.streamDoc(
        documentPath: PathService.user(userId),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
      );

  Future<List<FlybisUser>?> getUsersRecommendations() async =>
      await _db.getCollection(
        collectionPath: PathService.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15),
      );

  Future<void> configureUserPresence(String userId) async {
    final String path = PathService.status(userId);

    // We'll create two constants which we will write to
    // the Realtime database when this device is offline
    // or online.
    FlybisUserStatus isOfflineForDatabase = FlybisUserStatus(
      status: 'offline',
      timestamp: _rt.timestamp,
    );
    FlybisUserStatus isOnlineForDatabase = FlybisUserStatus(
      status: 'online',
      timestamp: _rt.timestamp,
    );

    // Firestore uses a different server timestamp value, so we'll
    // create two more constants for Firestore state.
    FlybisUserStatus isOfflineForFirestore = FlybisUserStatus(
      status: 'offline',
      timestamp: _db.serverTimestamp(),
    );
    FlybisUserStatus isOnlineForFirestore = FlybisUserStatus(
      status: 'online',
      timestamp: _db.serverTimestamp(),
    );

    _rt.onValue(path: '.info/connected').listen((var event) async {
      if (event.snapshot.value == false) {
        // Instead of simply returning, we'll also set Firestore's state
        // to 'offline'. This ensures that our Firestore cache is aware
        // of the switch to 'offline.'
        _db.set(
          documentPath: path,
          data: isOfflineForFirestore.toMap(),
        );

        return;
      }

      _rt
          .onDisconnect(path: path)
          .update(isOfflineForDatabase.toMap())
          .then((var snapshot) {
        _rt.set(
          path: path,
          data: isOnlineForDatabase.toMap(),
        );

        // We'll also add Firestore set here for when we come online.
        _db.set(
          documentPath: path,
          data: isOnlineForFirestore.toMap(),
        );
      });
    });
  }

  Future<void> configureUserFirestore(
    String uid,
    String? email,
    Function profileCreateView,
    Function introductionView,
  ) async {
    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    FlybisUser? flybisUser = await getUser(uid);

    logger.i('profileCreateView: ' + flybisUser.toString());

    if (flybisUser == null) {
      final Map<String, dynamic> result = await profileCreateView();

      logger.i('profileCreateView: ' + result['username']);

      if (result != null) {
        FlybisUser newFlybisUser = FlybisUser(
          uid: uid,
          email: email,
          username: result['username'],
          displayName: result['displayName'],
          bio: result['bio'],
          photoUrl: result['photoUrl'],
          timestamp: _db.serverTimestamp(),
          timestampBirthday: result['timestampBirthday'],
        );

        // Receive result from CreateProfile and set.
        await setUser(newFlybisUser);

        // Follow self auth.
        await followService.setFollower(uid, uid);

        flybisUser = await getUser(uid);
      }

      await introductionView();
    }

    if (flybisUser != null) {
      flybisUserOwner = flybisUser;

      authService.setUserOffline(flybisUserOwner);

      streamSubscription = streamUser(uid)!.listen(
        (FlybisUser flybisUser) {
          if (flybisUser != null) {
            flybisUserOwner = flybisUser;

            authService.setUserOffline(flybisUserOwner);
          } else {
            configureUserFirestore(
              uid,
              email,
              profileCreateView,
              introductionView,
            );
          }
        },
      );
    } else {
      configureUserFirestore(
        uid,
        email,
        profileCreateView,
        introductionView,
      );
    }
  }
}
