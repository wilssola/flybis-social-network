// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/flybis_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class FlybisService {
  FlybisService();

  final DatabaseService _db = DatabaseService.instance;

  Stream<List<FlybisIntroduction>> streamIntroductions() =>
      _db.streamCollection(
        collectionPath: PathService.flybis('introductions'),
        builder: (data, documentId) =>
            FlybisIntroduction.fromMap(data, documentId),
        queryBuilder: (query) => query.orderBy('page'),
      );

  Future<List<Map<String, dynamic>>> streamMinimumPostDurations() =>
      _db.getCollection(
        collectionPath: PathService.flybis('minimumPostDurations'),
        builder: (data, documentId) => data,
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(1),
      );
}
