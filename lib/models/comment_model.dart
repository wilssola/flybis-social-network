// 📦 Package imports:
import 'package:meta/meta.dart';

// 🌎 Project imports:
import 'package:flybis/plugins/timestamp.dart';

class FlybisComment {
  // User
  String? userId;

  // Comment
  String commentId;
  String commentContent;
  String? commentType; // posts, lives, stories

  // Timestamp
  dynamic timestamp;

  FlybisComment({
    // User
    required this.userId,

    // Comment
    required this.commentId,
    required this.commentContent,
    this.commentType: 'posts', // posts, lives, stories

    // Timestamp
    required this.timestamp,
  });

  factory FlybisComment.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    //if (data == null) {
    //return null;
    //}

    return FlybisComment(
      // User
      userId: data!['userId'] ?? '',

      // Content
      commentId: data['commentId'] ?? documentId,
      commentContent: data['commentContent'] ?? '',
      commentType: data['commentType'] ?? '',

      // Timestamp
      timestamp: data['timestamp'] ?? timestampNow(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // User
      'userId': this.userId ?? '',

      // Content
      'commentId': this.commentId,
      'commentContent': this.commentContent,
      'commentType': this.commentType ?? '',

      // Timestamp
      'timestamp': this.timestamp ?? timestampNow(),
    };
  }
}
