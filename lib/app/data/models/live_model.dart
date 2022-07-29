// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/timestamp.dart';

class FlybisLive {
  // ID's
  String? userId;
  String? liveId;

  // Status
  String? status;

  // Timestamp
  dynamic timestamp;

  FlybisLive({
    // ID's
    this.userId,
    this.liveId,

    // Status
    this.status = 'offline',

    // Timestamp
    this.timestamp,
  });

  factory FlybisLive.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    if (data == null) {
      return FlybisLive();
    }

    logger.d('FlybisLive.fromMap: ' + data.toString());

    return FlybisLive(
      // ID's
      userId: data['userId'] ?? documentId,
      liveId: data['liveId'] ?? '',

      // Status
      status: data['status'] ?? '',

      // Timestamp
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // ID's
      'userId': userId,
      'liveId': liveId,

      // Status
      'status': status,

      // Timestamp
      'timestamp': timestamp,
    };
  }
}

class FlybisLiveStatus {
  String? status;
  dynamic timestamp;

  FlybisLiveStatus({
    this.status = 'offline',
    this.timestamp,
  });

  factory FlybisLiveStatus.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    if (data == null) {
      return FlybisLiveStatus();
    }

    logger.d('FlybisLiveStatus.fromMap: ' + data.toString());

    return FlybisLiveStatus(
      status: data['status'],
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'timestamp': timestamp,
    };
  }
}
