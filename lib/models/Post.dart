import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String postId;
  final String ownerId;
  final String username;
  final String location;
  final String description;
  final String mediaUrl;

  final Map likes;
  final int likesCount;

  final Map dislikes;
  final int dislikesCount;

  final Timestamp timestamp;
  final Timestamp timestampDuration;
  final Timestamp timestampPopularity;

  Post({
    this.postId,
    this.ownerId,
    this.username,
    this.location,
    this.description,
    this.mediaUrl,

    // Likes
    this.likes,
    this.likesCount,

    // Dislikes
    this.dislikes,
    this.dislikesCount,

    // Timestamps
    this.timestamp,
    this.timestampDuration,
    this.timestampPopularity,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      postId: doc['postId'],
      ownerId: doc['ownerId'],
      username: doc['username'],
      location: doc['location'],
      description: doc['description'],
      mediaUrl: doc['mediaUrl'],

      // Likes
      likes: doc["likes"] != null ? doc["likes"] : {},
      likesCount: doc["likesCount"] != null ? doc["likesCount"] : 0,

      // Dislikes
      dislikes: doc["dislikes"] != null ? doc["dislikes"] : {},
      dislikesCount: doc["dislikesCount"] != null ? doc["dislikesCount"] : 0,

      // Timestamps
      timestamp: doc['timestamp'] != null
          ? doc['timestamp']
          : Timestamp.fromDate(DateTime.now()),
      timestampDuration: doc['timestampDuration'] != null
          ? doc['timestampDuration']
          : Timestamp.fromDate(DateTime.now()),
      timestampPopularity: doc['timestampPopularity'] != null
          ? doc['timestampPopularity']
          : Timestamp.fromDate(DateTime.now()),
    );
  }

  int getLikeOrDislikeCount(Map likesOrDislikes) {
    if (likesOrDislikes == {}) {
      return 0;
    }

    int count = 0;
    likesOrDislikes.values.forEach((value) {
      if (value == true) {
        count += 1;
      }
    });

    return count;
  }

  static checkTimestamp(duration, popularity) {
    final timestampDuration =
        duration != null ? duration.millisecondsSinceEpoch : 0;
    final timestampPopularity =
        popularity != null ? popularity.millisecondsSinceEpoch : 0;

    final endTimestamp =
        (timestampPopularity - timestampDuration) + timestampDuration;

    return endTimestamp;
  }

  static checkValidity(duration, popularity) {
    final endTimestamp = Post.checkTimestamp(
      duration,
      popularity,
    );

    final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

    final differenceTimestamp = endTimestamp - nowTimestamp;

    return differenceTimestamp > 0;
  }
}
