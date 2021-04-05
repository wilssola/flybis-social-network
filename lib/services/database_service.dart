// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';

/*
This class represent all possible CRUD operation for Firestore.
It contains all generic implementation needed based on the provided document
path and id,since most of the time in Firestore design, we will have
id and path for any document and collections.
*/
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  FieldValue serverTimestamp() {
    return FieldValue.serverTimestamp();
  }

  Future<List<T>> getCollection<T>({
    @required String collectionPath,
    @required T builder(Map<String, dynamic> data, String documentId),
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
  }) async {
    try {
      Query query = _db.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final QuerySnapshot snapshots = await query.get();

      final List<T> result = snapshots.docs
          .map((DocumentSnapshot snapshot) =>
              builder(snapshot.exists ? snapshot.data() : null, snapshot.id))
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

  Future<T> get<T>({
    @required String documentPath,
    @required T builder(Map<String, dynamic> data, String documentId),
    Source source = Source.serverAndCache,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      final DocumentSnapshot document =
          await reference.get(GetOptions(source: source));

      logger.i(
          'get: $documentPath data: ${document.exists ? document.data() : false}');

      return builder(document.exists ? document.data() : null, document.id);
    } catch (error) {
      logger.e(error);

      return null;
    }
  }

  Future<void> set({
    @required String documentPath,
    @required Map<String, dynamic> data,
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
    @required String documentPath,
    @required Map<String, dynamic> data,
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
    @required String documentPath,
  }) async {
    try {
      final DocumentReference reference = _db.doc(documentPath);

      logger.i('delete: $documentPath');

      await reference.delete();
    } catch (error) {
      logger.e(error);
    }
  }

  Future<T> getTransaction<T>({
    @required String documentPath,
    @required T builder(Map<String, dynamic> data, String documentId),
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

      return builder(document.exists ? document.data() : null, document.id);
    } catch (error) {
      logger.e(error);
    }
  }

  Future<void> setTransaction({
    @required String documentPath,
    @required Map<String, dynamic> data,
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
    @required String documentPath,
    @required Map<String, dynamic> data,
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
    @required String documentPath,
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

  Future<String> add({
    @required String collectionPath,
    @required Map<String, dynamic> data,
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
    @required String collectionPath,
    @required Map<String, dynamic> data,
    Query queryBuilder(Query query),
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
    @required String collectionPath,
    @required Map<String, dynamic> data,
    Query queryBuilder(Query query),
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
    @required String collectionPath,
    Query queryBuilder(Query query),
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

  Stream<List<T>> streamCollection<T>({
    @required String collectionPath,
    @required T builder(Map<String, dynamic> data, String documentId),
    Query queryBuilder(Query query),
    int sort(T lhs, T rhs),
  }) {
    try {
      Query query = _db.collection(collectionPath);
      if (queryBuilder != null) {
        query = queryBuilder(query);
      }

      final Stream<QuerySnapshot> snapshots = query.snapshots();

      return snapshots.map((QuerySnapshot snapshot) {
        final List<T> result = snapshot.docs
            .map((DocumentSnapshot snapshot) =>
                builder(snapshot.exists ? snapshot.data() : null, snapshot.id))
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

  Stream<T> streamDoc<T>({
    @required String documentPath,
    @required T builder(Map<String, dynamic> data, String documentId),
  }) {
    try {
      final DocumentReference reference = _db.doc(documentPath);
      final Stream<DocumentSnapshot> snapshots = reference.snapshots();

      return snapshots.map(
        (DocumentSnapshot snapshot) => builder(
          snapshot.exists ? snapshot.data() : null,
          snapshot.id,
        ),
      );
    } catch (error) {
      logger.e(error);
      return null;
    }
  }

  Future<void> bulkSet({
    @required String path,
    @required List<Map<String, dynamic>> datas,
    bool merge = false,
  }) async {
    final DocumentReference reference = _db.doc(path);
    final WriteBatch batchSet = _db.batch();

    logger.i('$path: $datas');
  }
}
