// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class SearchService {
  SearchService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Future<List<FlybisUser>?> getUserByDisplayName(
          String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: DatabasePath.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('displayNameQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('displayNameQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>?> getUserByUsername(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: DatabasePath.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('usernameQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('usernameQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>?> getUserByBio(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: DatabasePath.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('bioQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('bioQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>?> getUserByEmail(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: DatabasePath.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('email', isGreaterThanOrEqualTo: stringQuery)
            .where('email', isLessThan: stringQuery + 'z')
            .limit(limit),
      );
}
