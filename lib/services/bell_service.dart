// 🎯 Dart imports:
import 'dart:async';

// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/models/bell_model.dart';
import 'package:flybis/services/database_service.dart';
import 'package:flybis/services/path_service.dart';

class BellService {
  BellService();

  final DatabaseService _db = DatabaseService.instance;

  Stream<List<FlybisBell>> streamBells(
    String userId,
    int limit,
  ) =>
      _db.streamCollection(
        collectionPath: PathService.bells(userId),
        builder: (data, documentId) => FlybisBell.fromMap(data, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15 + limit),
      );
}
