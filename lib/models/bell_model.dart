// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/timestamp.dart';

class FlybisBell {
  // Reference
  dynamic ref;

  // Users
  String senderId;
  String receiverId;

  // Bell
  String bellId;
  FlybisBellContent bellContent;
  String bellMode; // comment, friend, follow, message

  // Timestamp
  dynamic timestamp;

  FlybisBell({
    // Reference
    this.ref,

    // Users
    this.senderId: '',
    this.receiverId: '',

    // Bell
    this.bellId: '',
    this.bellContent,
    this.bellMode: '', // comment, friend, follow, message

    // Timestamp
    this.timestamp,
  });

  factory FlybisBell.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    try {
      if (data == null) {
        return null;
      }

      logger.d('FlybisBell.fromMap: ' + data.toString());

      return FlybisBell(
        // Reference
        ref: data['ref'] ?? null,

        // Users
        senderId: data['senderId'] ?? '',
        receiverId: data['receiverId'] ?? '',

        // Bell
        bellId: data['bellId'] ?? '',
        bellContent: data['bellContent'] != null
            ? FlybisBellContent.fromMap(data['bellContent'])
            : FlybisBellContent(),
        bellMode: data['bellMode'] ?? '', // comment, friend, follow, message

        // Timestamp
        timestamp: data['timestamp'] ?? timestampNow(),
      );
    } catch (error) {
      logger.e('FlybisBell.fromMap: ' + error.toString());

      return null;
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        // Reference
        'ref': this.ref ?? null,

        // Users
        'senderId': this.senderId ?? '',
        'receiverId': this.receiverId ?? '',

        // Bell
        'bellId': this.bellId ?? '',
        'bellContent': this.bellContent != null
            ? this.bellContent.toMap()
            : FlybisBellContent().toMap(),
        'bellMode': this.bellMode ?? '', // comment, friend, follow, message

        // Timestamp
        'timestamp': this.timestamp ?? timestampNow(),
      };
    } catch (error) {
      logger.e('FlybisBell.toMap: ' + error.toString());

      return null;
    }
  }
}

class FlybisBellContent {
  final String contentId;
  final String contentType;
  final String contentText;
  final String contentImage;

  FlybisBellContent({
    this.contentId = '',
    this.contentType = '',
    this.contentText = '',
    this.contentImage = '',
  });

  factory FlybisBellContent.fromMap(
    Map<String, dynamic> data,
  ) {
    try {
      if (data == null) {
        return null;
      }

      logger.d('FlybisBellContent.fromMap: ' + data.toString());

      return FlybisBellContent(
        contentId: data['contentId'] ?? '',
        contentType: data['contentType'] ?? '',
        contentText: data['contentText'] ?? '',
        contentImage: data['contentImage'] ?? '',
      );
    } catch (error) {
      logger.e('FlybisBellContent.fromMap: ' + error.toString());

      return null;
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        'contentId': this.contentId ?? '',
        'contentType': this.contentType ?? '',
        'contentText': this.contentText ?? '',
        'contentImage': this.contentImage ?? '',
      };
    } catch (error) {
      logger.e('FlybisBellContent.toMap: ' + error.toString());

      return null;
    }
  }
}

class FlybisBellData {
  // Users
  final String senderId;
  final String receiverId;

  // Bell
  final FlybisBell bell;

  FlybisBellData({
    // Users
    @required this.senderId,
    @required this.receiverId,

    // Bell
    @required this.bell,
  });

  factory FlybisBellData.fromMap(
    Map<String, dynamic> data,
  ) {
    try {
      if (data == null) {
        return null;
      }

      logger.d('FlybisBellData.fromMap: ' + data.toString());

      return FlybisBellData(
        // Users
        senderId: data['senderId'],
        receiverId: data['receiverId'],

        // Bell
        bell: data['bell'] != null
            ? FlybisBell.fromMap(data['bell'], '')
            : FlybisBell(),
      );
    } catch (error) {
      logger.e('FlybisBellData.fromMap: ' + error.toString());

      return null;
    }
  }

  Map<String, dynamic> toMap() {
    try {
      return {
        // Users
        'senderId': this.senderId ?? '',
        'receiverId': this.receiverId ?? '',

        // Bell
        'bell': this.bell != null ? this.bell.toMap() : FlybisBell().toMap(),
      };
    } catch (error) {
      logger.e('FlybisBellData.toMap: ' + error.toString());

      return null;
    }
  }
}
