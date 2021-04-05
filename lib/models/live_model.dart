// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/timestamp.dart';

class FlybisLive {
  // ID's
  String userId;
  String liveId;

  // Status
  String status;

  // Timestamp
  dynamic timestamp;

  FlybisLive({
    // ID's
    this.userId,
    this.liveId,

    // Status
    this.status: 'offline',

    // Timestamp
    this.timestamp,
  });

  factory FlybisLive.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    logger.d('FlybisLive.fromMap: ' + data.toString());

    return FlybisLive(
      // ID's
      userId: data['userId'] != null ? data['userId'] : documentId,
      liveId: data['liveId'] != null ? data['liveId'] : '',

      // Status
      status: data['status'] != null ? data['status'] : '',

      // Timestamp
      timestamp: data['timestamp'] != null ? data['timestamp'] : timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // ID's
      'userId': this.userId,
      'liveId': this.liveId,

      // Status
      'status': this.status,

      // Timestamp
      'timestamp': this.timestamp,
    };
  }
}

class FlybisLiveStatus {
  String status;
  dynamic timestamp;

  FlybisLiveStatus({
    this.status: 'offline',
    this.timestamp,
  });

  factory FlybisLiveStatus.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    logger.d('FlybisLiveStatus.fromMap: ' + data.toString());

    return FlybisLiveStatus(
      status: data['status'],
      timestamp: data['timestamp'] != null ? data['timestamp'] : timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': this.status,
      'timestamp': this.timestamp,
    };
  }
}
