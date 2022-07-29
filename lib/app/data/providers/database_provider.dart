// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';

class DatabaseProvider {
  DatabaseProvider._();
  static final DatabaseProvider instance = DatabaseProvider._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }

  Future<List<T>?> getCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) async {
    try {
      Query query = _db.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final QuerySnapshot snapshots = await query.get();

      final List<T> result = snapshots.docs
          .map(
            (DocumentSnapshot snapshot) => builder(
              snapshot.exists ? snapshot.data() as Map<String, dynamic>? : null,
              snapshot.id,
            ),
          )
          .where((value) => value != null)
          .toList();

      if (sort != null) {
        result.sort(sort);
      }

      return result;
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  Future<T?> get<T>({
    required String documentPath,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
    Source source = Source.serverAndCache,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      final DocumentSnapshot document =
          await reference.get(GetOptions(source: source));

      logger.i(
          'get: $documentPath data: ${document.exists ? document.data() : false}');

      return builder(
          document.exists ? document.data() as Map<String, dynamic>? : null,
          document.id);
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  Future<void> set({
    required String documentPath,
    required Map<String, dynamic>? data,
    bool merge = false,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('set: $documentPath data: $data');

      await reference.set(data, SetOptions(merge: merge));
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> update({
    required String documentPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('update: $documentPath data: $data');

      await reference.update(data);
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> delete({
    required String documentPath,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('delete: $documentPath');

      await reference.delete();
    } catch (error) {
      logger.e(error);
    }
  }

  Future<T?> getTransaction<T>({
    required String documentPath,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('getTransaction: $documentPath');

      final DocumentSnapshot document = await _db.runTransaction((
        Transaction transaction,
      ) async {
        return await transaction.get(
          reference,
        );
      });

      return builder(
          document.exists ? document.data() as Map<String, dynamic>? : null,
          document.id);
    } catch (error) {
      logger.e(error);
    }
    return null;
  }

  Future<void> setTransaction({
    required String documentPath,
    required Map<String, dynamic>? data,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('setTransaction: $documentPath data: $data');

      await _db.runTransaction((
        Transaction transaction,
      ) async {
        transaction.set(
          reference,
          data,
        );
      });
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> updateTransaction({
    required String documentPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('updateTransaction: $documentPath data: $data');

      await _db.runTransaction((
        Transaction transaction,
      ) async {
        transaction.update(
          reference,
          data,
        );
      });
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> deleteTransaction({
    required String documentPath,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('deleteTransaction: $documentPath');

      await _db.runTransaction((
        Transaction transaction,
      ) async {
        transaction.delete(
          reference,
        );
      });
    } catch (error) {
      logger.e(error);
    }
  }

  Future<String?> add({
    required String collectionPath,
    required Map<String, dynamic> data,
  }) async {
    try {
      final CollectionReference reference = _db.collection(collectionPath);

      final DocumentReference document = await reference.add(data);

      final String documentPath = document.path;

      logger.i('add: $documentPath data: $data');

      return documentPath;
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  Future<void> setBatch({
    required String collectionPath,
    required Map<String, dynamic> data,
    Query Function(Query query)? queryBuilder,
    bool merge = false,
  }) async {
    try {
      final WriteBatch batch = _db.batch();

      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        batch.set(document.reference, data, SetOptions(merge: merge));
      }

      await batch.commit();
    } catch (error) {
      logger.e(error);
    }
  }

  Future updateBatch({
    required String collectionPath,
    required Map<String, dynamic> data,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      final WriteBatch batch = _db.batch();

      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        batch.update(document.reference, data);
      }

      await batch.commit();
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> deleteBatch({
    required String collectionPath,
    Query Function(Query query)? queryBuilder,
  }) async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();

      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection(collectionPath).get();

      for (DocumentSnapshot document in querySnapshot.docs) {
        batch.delete(document.reference);
      }

      await batch.commit();
    } catch (error) {
      logger.e(error);
    }
  }

  Stream<List<T>>? streamCollection<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
    Query Function(Query query)? queryBuilder,
    int Function(T lhs, T rhs)? sort,
  }) {
    try {
      Query query = _db.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final Stream<QuerySnapshot> snapshots = query.snapshots();

      return snapshots.map((QuerySnapshot snapshot) {
        final List<T> result = snapshot.docs
            .map(
              (DocumentSnapshot snapshot) => builder(
                snapshot.exists
                    ? snapshot.data() as Map<String, dynamic>?
                    : null,
                snapshot.id,
              ),
            )
            .where((value) => value != null)
            .toList();

        if (sort != null) {
          result.sort(sort);
        }

        logger.i(
            'streamCollection: $collectionPath data: $result  length: ${result.length}');

        return result;
      });
    } catch (error) {
      logger.e(error);
      return null;
    }
  }

  Stream<T>? streamDoc<T>({
    required String documentPath,
    required T Function(Map<String, dynamic>? data, String documentId) builder,
  }) {
    try {
      final DocumentReference reference = _db.doc(documentPath);
      final Stream<DocumentSnapshot> snapshots = reference.snapshots();

      return snapshots.map(
        (DocumentSnapshot snapshot) => builder(
          snapshot.exists ? snapshot.data() as Map<String, dynamic>? : null,
          snapshot.id,
        ),
      );
    } catch (error) {
      logger.e(error);
      return null;
    }
  }

  Future<void> bulkSet({
    required String path,
    required List<Map<String, dynamic>> datas,
    bool merge = false,
  }) async {
    final DocumentReference reference = _db.doc(path);
    final WriteBatch batchSet = _db.batch();

    logger.i('$path: $datas');
  }
}
