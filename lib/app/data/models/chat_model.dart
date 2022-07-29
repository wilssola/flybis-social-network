// 📦 Package imports:

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/timestamp.dart';

class FlybisChatStatus {
  // Chat
  String chatId;
  String chatKey;
  String chatType; // direct, group
  List<String?> chatUsers;

  // Message
  String messageContent;
  String messageType; // text, image, video, giphy
  int messageColor;
  Map<String?, int>? messageCounts;

  // Timestamp
  dynamic timestamp;

  FlybisChatStatus({
    // Chat
    required this.chatId,
    required this.chatKey,
    required this.chatType,
    required this.chatUsers,

    // Message
    this.messageContent = '',
    this.messageType = 'text', // text, image, video, giphy
    this.messageColor = 0,
    this.messageCounts,

    // Timestamp
    this.timestamp,
  });

  factory FlybisChatStatus.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    //if (data == null) {
    //return null;
    //}

    return FlybisChatStatus(
      // Chat
      chatId: data!['chatId'] ?? documentId,
      chatKey: data['chatKey'] ?? '',
      chatType: data['chatType'] ?? '',
      chatUsers: data['chatUsers'] ?? [],

      // Message
      messageContent: data['messageContent'] ?? '',
      messageType: data['messageType'] ?? '', // text, image, video, giphy
      messageColor: data['messageColor'] ?? 0,
      messageCounts: data['messageCounts'] ?? {},

      // Timestamp
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // Chat
      'chatId': chatId,
      'chatKey': chatKey,
      'chatUsers': chatUsers,

      // Message
      'messageContent': messageContent,
      'messageType': messageType, // text, image, video, giphy
      'messageColor': messageColor,
      'messageCounts': messageCounts ?? {},

      // Timestamp
      'timestamp': timestamp ?? timestampNow(),
    };
  }
}

class FlybisChatMessage {
  // Chat
  final String? chatId;

  // User
  final String? userId;

  // Message
  final String? messageId;
  final String? messageContent;
  final String? messageType; // text, image, video, giphy
  final int? messageColor;

  // Timestamp
  dynamic timestamp;

  FlybisChatMessage({
    // Chat
    required this.chatId,

    // Users
    this.userId = '',

    // Message
    required this.messageId,
    this.messageContent = '',
    this.messageType = 'text', // text, image, video, giphy
    this.messageColor = 0,

    // Timestamp
    this.timestamp,
  });

  factory FlybisChatMessage.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    //if (data == null) {
    //return null;
    //}

    return FlybisChatMessage(
      // Chat
      chatId: data!['chatId'] != null ? data['chatId'] : '',

      // Users
      userId: data['userId'] ?? '',

      // Message
      messageId: data['messageId'] ?? documentId,
      messageContent:
          data['messageContent'] ?? '',
      messageType: data['messageType'] ?? '',
      messageColor:
          data['messageColor'] ?? '' as int?,

      // Timestamp
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic>? toMap() {
    try {
      return {
        // Chat
        'chatId': chatId,

        // Users
        'userId': userId,

        // Message
        'messageId': messageId,
        'messageContent': messageContent,
        'messageType': messageType,
        'messageColor': messageColor,

        // Timestamp
        'timestamp': timestamp,
      };
    } catch (error) {
      logger.e(error);

      return null;
    }
  }
}
