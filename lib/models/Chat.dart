import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  // Users
  final String uid;
  final String peerId;

  // Content
  final String content;
  final String type; // like, follow, comment, message
  final int color;

  // Time
  final Timestamp timestamp;

  ChatMessage({
    // Users
    this.uid,
    this.peerId,

    // Content
    this.content,
    this.type,
    this.color,

    // Time
    this.timestamp,
  });

  factory ChatMessage.fromDocument(DocumentSnapshot doc) {
    return ChatMessage(
      // Users
      uid: doc['uid'] != null ? doc['uid'] : '',
      peerId: doc['peerId'] != null ? doc['peerId'] : '',

      // Content
      content: doc['content'] != null ? doc['content'] : '',
      type: doc['type'] != null ? doc['type'] : '',
      color: doc['color'] != null ? doc['color'] : 0,

      // Time
      timestamp: doc['timestamp'] != null
          ? doc['timestamp']
          : Timestamp.fromDate(DateTime.now()),
    );
  }
}

class ChatStatus {
  final String lastMessageContent;
  final String lastMessageType;
  final Timestamp lastMessageTimestamp;
  final int lastMessageColor;

  ChatStatus({
    this.lastMessageContent,
    this.lastMessageType,
    this.lastMessageTimestamp,
    this.lastMessageColor,
  });
}
