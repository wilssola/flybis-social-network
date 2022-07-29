// 📦 Package imports:
import 'package:firebase_database/firebase_database.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';

/*
This class represent all possible CRUD operation for Firestore.
It contains all generic implementation needed based on the provided document
path and id,since most of the time in Firestore design, we will have
id and path for any document and collections.
*/
class RealtimeProvider {
  RealtimeProvider._();
  static final RealtimeProvider instance = RealtimeProvider._();

  final DatabaseReference _rt = FirebaseDatabase.instance.ref();

  Map<String, String> timestamp() {
    return ServerValue.timestamp;
  }

  Future<DatabaseEvent> once<T>({
    required String path,
  }) async {
    final DatabaseReference reference = _rt.child(path);

    logger.i('once: $path');

    return reference.once();
  }

  Stream<DatabaseEvent> onValue<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onValue: $path');

    return reference.onValue;
  }

  Stream<DatabaseEvent> onChildAdded<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onChildAdded: $path');

    return reference.onChildAdded;
  }

  Stream<DatabaseEvent> onChildChanged<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onChildChanged: $path');

    return reference.onChildChanged;
  }

  Stream<DatabaseEvent> onChildMoved<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onChildMoved: $path');

    return reference.onChildMoved;
  }

  Stream<DatabaseEvent> onChildRemoved<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onChildRemoved: $path');

    return reference.onChildRemoved;
  }

  OnDisconnect onDisconnect<T>({
    required String path,
  }) {
    final DatabaseReference reference = _rt.child(path);

    logger.i('onDisconnect: $path');

    return reference.onDisconnect();
  }

  Future<void> set({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    final DatabaseReference reference = _rt.child(path);

    logger.i('set: $path data: $data');

    await reference.set(data);
  }

  Future<void> update({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    final DatabaseReference reference = _rt.child(path);

    logger.i('update: $path data: $data');

    await reference.update(data);
  }

  Future<void> remove({
    required String path,
  }) async {
    final DatabaseReference reference = _rt.child(path);

    logger.i('delete: $path');

    await reference.remove();
  }
}
