// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/core/values/database_path.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/app/data/providers/auth_provider.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/app/data/providers/realtime_provider.dart';
import 'package:flybis/app/data/services/follow_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() => _instance;

  UserService._internal() {
    _flybisUserOwner = null;
    flybisUserOwnerStream = null;
  }

  FlybisUser? _flybisUserOwner;

  FlybisUser? get flybisUserOwner => _flybisUserOwner;
  set flybisUserOwner(FlybisUser? value) => _flybisUserOwner = value;

  StreamSubscription? flybisUserOwnerStream;

  final DatabaseProvider _db = DatabaseProvider.instance;
  final RealtimeProvider _rt = RealtimeProvider.instance;
  final AuthProvider _auth = AuthProvider.instance;

  final FollowService followService = FollowService();

  Future<String?> getUsername(String username) async => await _db.get(
        documentPath: DatabasePath.username(username),
        builder: (data, documentId) => data != null ? data['uid'] : null,
      );

  Future<void> setUser(FlybisUser user) async => await _db.set(
        documentPath: DatabasePath.user(user.uid),
        data: user.toMap(),
      );

  Future<void> updateUser(String? userId, FlybisUser user) async => await _db
      .update(documentPath: DatabasePath.user(userId), data: user.toMap());

  Future<FlybisUser?> getUser(String? userId) async => await _db.get(
        documentPath: DatabasePath.user(userId),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
      );

  Stream<FlybisUser>? streamUser(String? userId) => _db.streamDoc(
        documentPath: DatabasePath.user(userId),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
      );

  Future<List<FlybisUser>?> getUsersRecommendations() async =>
      await _db.getCollection(
        collectionPath: DatabasePath.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15),
      );

  Future<void> configureUserPresence(String userId) async {
    final String path = DatabasePath.status(userId);

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
    String email,
    Function showProfileCreateView,
    Function introductionView,
  ) async {
    if (flybisUserOwnerStream != null) flybisUserOwnerStream!.cancel();

    FlybisUser? flybisUser = await getUser(uid);

    flybisUser ??= await createUserFirestore(
      uid,
      email,
      showProfileCreateView,
      introductionView,
    );

    if (flybisUser == null) {
      return configureUserFirestore(
        uid,
        email,
        showProfileCreateView,
        introductionView,
      );
    }

    // Caso o usuário exista, flybisUserOwner será definido e será salvo para uso offline.
    flybisUserOwner = flybisUser;
    _auth.setUserOffline(flybisUserOwner!);

    // Listener para verificar constantemente se o usuário existe.
    flybisUserOwnerStream = streamUser(uid)!.listen(
      (onData) => listenUser(
        onData,
        uid,
        email,
        showProfileCreateView,
        introductionView,
      ),
    );
  }

  Future<FlybisUser?> createUserFirestore(
    String uid,
    String email,
    Function showProfileCreateView,
    Function introductionView,
  ) async {
    Map<String, dynamic>? result = await showProfileCreateView();
    while (result == null) {
      result = await showProfileCreateView();
    }

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

    logger.i('newFlybisUser:', newFlybisUser.toMap());

    // Receive result and set new user.
    await setUser(newFlybisUser);

    // Follow self.
    await followService.setFollower(uid, uid);

    // Receive new user.
    FlybisUser? flybisUser = await getUser(uid);

    if (flybisUser != null) await introductionView();

    return flybisUser;
  }

  void listenUser(
    FlybisUser? flybisUser,
    String uid,
    String email,
    Function showProfileCreateView,
    Function introductionView,
  ) {
    // Caso o usuário exista, flybisUserOwner será definido e será salvo para uso offline.
    if (flybisUser != null) return;

    // Caso o usuário não exista um novo será criado.
    configureUserFirestore(
      uid,
      email,
      showProfileCreateView,
      introductionView,
    );
  }
}
