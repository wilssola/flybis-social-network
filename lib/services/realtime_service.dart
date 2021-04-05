// 📦 Package imports:
import 'package:firebase_database/firebase_database.dart';
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';

/*
This class represent all possible CRUD operation for Firestore.
It contains all generic implementation needed based on the provided document
path and id,since most of the time in Firestore design, we will have
id and path for any document and collections.
*/
class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  static final DatabaseReference _db = FirebaseDatabase.instance.reference();

  Map<String, String> timestamp() {
    return ServerValue.timestamp;
  }

  Future<DataSnapshot> once<T>({
    @required String path,
  }) async {
    final DatabaseReference reference = _db.child(path);

    logger.i('once: $path');

    return reference.once();
  }

  Stream<Event> onValue<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onValue: $path');

    return reference.onValue;
  }

  Stream<Event> onChildAdded<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onChildAdded: $path');

    return reference.onChildAdded;
  }

  Stream<Event> onChildChanged<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onChildChanged: $path');

    return reference.onChildChanged;
  }

  Stream<Event> onChildMoved<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onChildMoved: $path');

    return reference.onChildMoved;
  }

  Stream<Event> onChildRemoved<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onChildRemoved: $path');

    return reference.onChildRemoved;
  }

  OnDisconnect onDisconnect<T>({
    @required String path,
  }) {
    final DatabaseReference reference = _db.child(path);

    logger.i('onDisconnect: $path');

    return reference.onDisconnect();
  }

  Future<void> set({
    @required String path,
    @required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final DatabaseReference reference = _db.child(path);

    logger.i('set: $path data: $data');

    await reference.set(data);
  }

  Future<void> update({
    @required String path,
    @required Map<String, dynamic> data,
  }) async {
    final DatabaseReference reference = _db.child(path);

    logger.i('update: $path data: $data');

    await reference.update(data);
  }

  Future<void> remove({
    @required String path,
  }) async {
    final DatabaseReference reference = _db.child(path);

    logger.i('delete: $path');

    await reference.remove();
  }
}
