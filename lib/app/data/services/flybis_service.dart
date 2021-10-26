// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/flybis_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class FlybisService {
  FlybisService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Stream<List<FlybisIntroduction>>? streamIntroductions() =>
      _db.streamCollection(
        collectionPath: DatabasePath.flybis('introductions'),
        builder: (data, documentId) =>
            FlybisIntroduction.fromMap(data!, documentId),
        queryBuilder: (query) => query.orderBy('page'),
      );

  Future<List<Map<String, dynamic>>?> streamMinimumPostDurations() =>
      _db.getCollection(
        collectionPath: DatabasePath.flybis('minimumPostDurations'),
        builder: (data, documentId) => data!,
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(1),
      );
}
