// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/document_model.dart';
import 'package:flybis/models/user_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class SearchService {
  SearchService();

  final DatabaseService _db = DatabaseService.instance;

  Future<List<FlybisUser>> getUserByDisplayName(
          String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: PathService.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('displayNameQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('displayNameQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>> getUserByUsername(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: PathService.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('usernameQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('usernameQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>> getUserByBio(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: PathService.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('bioQuery', isGreaterThanOrEqualTo: stringQuery)
            .where('bioQuery', isLessThan: stringQuery + 'z')
            .limit(limit),
      );

  Future<List<FlybisUser>> getUserByEmail(String stringQuery, int limit) =>
      _db.getCollection(
        collectionPath: PathService.users(),
        builder: (data, documentId) => FlybisUser.fromMap(data, documentId),
        queryBuilder: (query) => query
            .where('email', isGreaterThanOrEqualTo: stringQuery)
            .where('email', isLessThan: stringQuery + 'z')
            .limit(limit),
      );
}
