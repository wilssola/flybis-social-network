// 🌎 Project imports:
import 'package:flybis/plugins/timestamp.dart';

class FlybisComment {
  // User
  final String userId;

  // Comment
  final String commentId;
  final String commentType; // posts, lives, stories
  String commentContent;

  // Timestamp
  dynamic timestamp;

  FlybisComment({
    // User
    required this.userId,

    // Comment
    required this.commentId,
    this.commentType: 'posts', // posts, lives, stories
    required this.commentContent,

    // Timestamp
    required this.timestamp,
  });

  factory FlybisComment.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return FlybisComment(
      // User
      userId: data['userId'] ?? '',

      // Content
      commentId: data['commentId'] ?? documentId,
      commentType: data['commentType'] ?? '',
      commentContent: data['commentContent'] ?? '',

      // Timestamp
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // User
      'userId': this.userId,

      // Content
      'commentId': this.commentId,
      'commentType': this.commentType,
      'commentContent': this.commentContent,

      // Timestamp
      'timestamp': this.timestamp ?? timestampNow(),
    };
  }
}
