import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  // Owner
  final String uid;
  final String username;

  // Post
  final String id;
  final String title;
  final String location;
  final String description;

  // Content
  final String contentUrl;
  final String contentType;

  // Likes
  final Map likes;
  final int likesCount;

  // Dislikes
  final Map dislikes;
  final int dislikesCount;

  // Timestamps
  final Timestamp timestamp;
  final Timestamp timestampDuration;
  final Timestamp timestampPopularity;

  // BlurHash
  final String blurHash;

  Post({
    // Owner
    this.uid,
    this.username,

    // Post
    this.id,
    this.title,
    this.location,
    this.description,

    // Content
    this.contentUrl,
    this.contentType,

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

    // BlurHash
    this.blurHash,
  });

  factory Post.fromDocument(DocumentSnapshot doc) {
    return Post(
      // Owner
      uid: doc['uid'],
      username: doc['username'],

      // Post
      id: doc['id'],
      title: doc['title'],
      location: doc['location'],
      description: doc['description'],

      // Content
      contentUrl: doc['contentUrl'],
      contentType: doc['contentType'] != null ? doc['contentType'] : 'image',

      // Likes
      likes: doc['likes'] != null ? doc['likes'] : {},
      likesCount: doc['likesCount'] != null ? doc['likesCount'] : 0,

      // Dislikes
      dislikes: doc['dislikes'] != null ? doc['dislikes'] : {},
      dislikesCount: doc['dislikesCount'] != null ? doc['dislikesCount'] : 0,

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

      // BlurHash
      blurHash: doc['blurHash'],
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
    final endTimestamp = Post.checkTimestamp(duration, popularity);

    final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

    final differenceTimestamp = endTimestamp - nowTimestamp;

    return differenceTimestamp > 0;
  }
}
