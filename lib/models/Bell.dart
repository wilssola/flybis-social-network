import 'package:cloud_firestore/cloud_firestore.dart';

class Bell {
  // Owner
  final String ownerUid;

  // User
  final String uid;
  final String username;
  final String photoUrl;

  // Content
  final String id;
  final String content;
  final String contentType; // text, image, video

  // Feed
  final String type; // like, follow, comment, message, friend
  final String data;
  final Timestamp timestamp;

  Bell({
    // Owner
    this.ownerUid,

    // User
    this.uid,
    this.username,
    this.photoUrl,

    // Content
    this.id,
    this.content,
    this.contentType,

    // Feed
    this.type,
    this.data,
    this.timestamp,
  });

  factory Bell.fromDocument(DocumentSnapshot doc) {
    return Bell(
      // Owner
      ownerUid: doc[
          'ownerUid'], // Example: For Grant the right of Owner to view quickly your Posts with Bell's

      // User
      uid: doc['uid'],
      username: doc['username'],
      photoUrl: doc['photoUrl'],

      // Content
      id: doc['id'],
      content: doc['content'],
      contentType: doc['contentType'], // For chat or comment

      // Feed
      type: doc['type'],
      data: doc['data'],
      timestamp: doc['timestamp'],
    );
  }
}
