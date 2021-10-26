// 🎯 Dart imports:
import 'dart:async';

// 🌎 Project imports:
import 'package:flybis/app/data/models/bell_model.dart';
import 'package:flybis/app/data/providers/database_provider.dart';
import 'package:flybis/core/values/database_path.dart';

class BellService {
  BellService();

  final DatabaseProvider _db = DatabaseProvider.instance;

  Stream<List<FlybisBell>>? streamBells(
    String? userId,
    int limit,
  ) =>
      _db.streamCollection(
        collectionPath: DatabasePath.bells(userId),
        builder: (data, documentId) => FlybisBell.fromMap(data!, documentId),
        queryBuilder: (query) =>
            query.orderBy('timestamp', descending: true).limit(15 + limit),
      );
}
