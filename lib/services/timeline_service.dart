// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/post_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class TimelineService {
  TimelineService();

  final DatabaseService _db = DatabaseService.instance;

  Stream<List<FlybisPost>>? streamTimeline(String? userId, int limit) =>
      _db.streamCollection(
        collectionPath: PathService.timelinePosts(userId),
        builder: (data, documentId) => FlybisPost.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(5 + limit),
      );
}
