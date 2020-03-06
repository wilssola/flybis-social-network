import 'package:cloud_firestore/cloud_firestore.dart';

class Feed {
  // Owner
  final String uid;
  final String username;
  final String photoUrl;

  // Content
  final String id;
  final String contentUrl;
  final String contentType;

  // Feed
  final String type; // like, follow, comment, message
  final String data;
  final Timestamp timestamp;

  Feed({
    // Owner
    this.uid,
    this.username,
    this.photoUrl,

    // Content
    this.id,
    this.contentUrl,
    this.contentType,

    // Feed
    this.type,
    this.data,
    this.timestamp,
  });

  factory Feed.fromDocument(DocumentSnapshot doc) {
    return Feed(
      // Owner
      uid: doc['uid'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],

      // Content
      id: doc['id'],
      contentUrl: doc['contentUrl'],
      contentType: doc['contentType'],

      // Feed
      type: doc['type'],
      data: doc['data'],
      timestamp: doc['timestamp'],
    );
  }
}
