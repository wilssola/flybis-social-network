// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:flybis/models/live_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';
import 'package:flybis/services/realtime_service.dart';

class LiveService {
  LiveService();

  final DatabaseService _db = DatabaseService.instance;
  final RealtimeService _rt = RealtimeService.instance;

  Future<void> startLive(String? userId, FlybisLive live) async {
    await configureLivePresence(userId);

    await setLive(userId, live);
  }

  FlybisLive createLive(String? userId) {
    return FlybisLive(
      userId: userId,
      liveId: Uuid().v4(),
      timestamp: _db.serverTimestamp(),
    );
  }

  Future<void> setLive(String? userId, FlybisLive live) async {
    await _db.set(
      documentPath: PathService.live(userId),
      data: live.toMap(),
    );
  }

  Future<void> deleteLive(String userId) async {
    await _db.delete(
      documentPath: PathService.live(userId),
    );
  }

  Stream<List<FlybisLive?>>? streamLives(int limit) => _db.streamCollection(
        collectionPath: PathService.lives(),
        builder: (data, documentId) => FlybisLive.fromMap(data, documentId),
        //queryBuilder: (query) =>
        //query.orderBy('timestamp', descending: true).limit(5 + limit),
      );

  Future<void> configureLivePresence(String? userId) async {
    final String path = PathService.live(userId);

    FlybisLiveStatus isOfflineForDatabase = FlybisLiveStatus(
      status: 'offline',
      timestamp: _rt.timestamp,
    );
    FlybisLiveStatus isOnlineForDatabase = FlybisLiveStatus(
      status: 'online',
      timestamp: _rt.timestamp,
    );

    FlybisLiveStatus isOfflineForFirestore = FlybisLiveStatus(
      status: 'offline',
      timestamp: _db.serverTimestamp(),
    );
    FlybisLiveStatus isOnlineForFirestore = FlybisLiveStatus(
      status: 'online',
      timestamp: _db.serverTimestamp(),
    );

    _rt.onValue(path: '.info/connected').listen((var event) async {
      if (event.snapshot.value == false) {
        _db.set(
          documentPath: path,
          data: isOfflineForFirestore.toMap(),
        );

        return;
      }

      await _rt
          .onDisconnect(path: path)
          .update(isOfflineForDatabase.toMap())
          .then((var snapshot) {
        _rt.set(
          path: path,
          data: isOnlineForDatabase.toMap(),
        );

        _db.update(
          documentPath: path,
          data: isOnlineForFirestore.toMap(),
        );
      });
    });
  }
}
