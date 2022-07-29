// 🌎 Project imports:
import 'package:flybis/global.dart';

class FlybisBell {
  // Reference
  final dynamic ref;

  // Users
  final String senderId;
  final String receiverId;

  // Bell
  final String bellId;
  final FlybisBellContent bellContent;
  final String bellMode; // comment, friend, follow, message

  // Timestamp
  final dynamic timestamp;

  FlybisBell({
    // Reference
    required this.ref,

    // Users
    required this.senderId,
    required this.receiverId,

    // Bell
    required this.bellId,
    required this.bellContent,
    required this.bellMode, // comment, friend, follow, message

    // Timestamp
    required this.timestamp,
  });

  factory FlybisBell.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    logger.d('FlybisBell.fromMap: ' + data.toString());

    return FlybisBell(
      // Reference
      ref: data['ref'],

      // Users
      senderId: data['senderId'],
      receiverId: data['receiverId'],

      // Bell
      bellId: data['bellId'],
      bellContent: FlybisBellContent.fromMap(data['bellContent']),
      bellMode: data['bellMode'], // comment, friend, follow, message

      // Timestamp
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Reference
      'ref': ref,

      // Users
      'senderId': senderId,
      'receiverId': receiverId,

      // Bell
      'bellId': bellId,
      'bellContent': bellContent.toMap(),
      'bellMode': bellMode, // comment, friend, follow, message

      // Timestamp
      'timestamp': timestamp,
    };
  }
}

class FlybisBellContent {
  final String contentId;
  final String contentType;
  final String contentText;
  final String contentImage;

  FlybisBellContent({
    required this.contentId,
    required this.contentType,
    this.contentText = '',
    this.contentImage = '',
  });

  factory FlybisBellContent.fromMap(
    Map<String, dynamic> data,
  ) {
    logger.d('FlybisBellContent.fromMap: ' + data.toString());

    return FlybisBellContent(
      contentId: data['contentId'] ?? '',
      contentType: data['contentType'] ?? '',
      contentText: data['contentText'] ?? '',
      contentImage: data['contentImage'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentId': contentId,
      'contentType': contentType,
      'contentText': contentText,
      'contentImage': contentImage,
    };
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
    required this.senderId,
    required this.receiverId,

    // Bell
    required this.bell,
  });

  factory FlybisBellData.fromMap(
    Map<String, dynamic> data,
  ) {
    logger.d('FlybisBellData.fromMap: ' + data.toString());

    return FlybisBellData(
      // Users
      senderId: data['senderId'],
      receiverId: data['receiverId'],

      // Bell
      bell: FlybisBell.fromMap(data['bell'], ''),
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      // Users
      'senderId': senderId,
      'receiverId': receiverId,

      // Bell
      'bell': bell.toMap(),
    };

    logger.d('FlybisBellData.toMap: ' + data.toString());

    return data;
  }
}
