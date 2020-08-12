import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String uid;
  final String email;

  final String username;
  final String displayName;
  final String bio;

  final String photoUrl;
  final String bannerUrl;

  final int followers;
  final int following;

  User({
    this.uid = '',
    this.email = '',
    this.username = '',
    this.displayName = '',
    this.bio = '',
    this.photoUrl = '',
    this.bannerUrl = '',
    this.followers = 0,
    this.following = 0,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      uid: doc['uid'] != null ? doc['uid'] : '',
      email: doc['email'] != null ? doc['email'] : '',
      username: doc['username'] != null ? doc['username'] : '',
      displayName: doc['displayName'] != null ? doc['displayName'] : '',
      bio: doc['bio'] != null ? doc['bio'] : '',
      photoUrl: doc['photoUrl'] != null ? doc['photoUrl'] : '',
      bannerUrl: doc['bannerUrl'] != null ? doc['bannerUrl'] : '',
      followers: doc['followers'] != null ? doc['followers'] : 0,
      following: doc['following'] != null ? doc['following'] : 0,
    );
  }
}
