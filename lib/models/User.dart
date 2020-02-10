import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;

  final String username;
  final String displayName;
  final String bio;

  final String photoUrl;
  final String bannerUrl;

  final int followers;
  final int following;

  User({
    this.id,
    this.email,

    this.username,
    this.displayName,
    this.bio,

    this.photoUrl,
    this.bannerUrl,

    this.followers,
    this.following,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    return User(
      id: doc['id'] != null ? doc['id'] : "",
      email: doc['email'] != null ? doc['email'] : "",

      username: doc['username'] != null ? doc['username'] : "",
      displayName:
          doc['displayName'] != null ? doc['displayName'] : "",
      bio: doc['bio'] != null ? doc['bio'] : "",

      photoUrl: doc['photoUrl'] != null ? doc['photoUrl'] : "",
      bannerUrl: doc['bannerUrl'] != null ? doc['bannerUrl'] : "",

      followers: doc['followers'] != null ? doc['followers'] : 0,
      following: doc['following'] != null ? doc['following'] : 0,
    );
  }
}
