// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class TimelineService {
  TimelineService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Stream<List<FlybisPost>>? streamTimeline(String? userId, int limit) =>
      _db.streamCollection(
        collectionPath: DatabasePath.timelinePosts(userId),
        builder: (data, documentId) => FlybisPost.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(5 + limit),
      );
}
