// Firebase

// 🌎 Project imports:
import 'package:flybis/global.dart';

class FlybisUser {
  // Firebase Auth
  final String uid;
  String? email;
  String? photoUrl;
  String? displayName;
  final String? displayNameQuery;

  // Flybis Auth
  final String? username;
  final String? usernameQuery;
  String? bio;
  final String? bioQuery;
  final Map? bioSentiment;
  String? bannerUrl;

  // Counts
  final int? followersCount;
  final int? followingsCount;
  final int? friendsCount;
  final int? postsCount;

  // BlurHash
  final String? blurHash;

  // Premium
  final bool? hasPremium;
  final bool? hasVerified;

  // Timestamp
  final dynamic timestamp;
  final dynamic timestampBirthday;

  FlybisUser({
    // Firebase Auth
    this.uid: '',
    this.email: '',
    this.photoUrl: '',
    this.displayName: '',
    this.displayNameQuery: '',

    // Flybis Auth
    this.username: '',
    this.usernameQuery: '',
    this.bio: '',
    this.bioQuery: '',
    this.bioSentiment,
    this.bannerUrl: '',

    // Counts
    this.followersCount: 0,
    this.followingsCount: 0,
    this.friendsCount: 0,
    this.postsCount: 0,

    // BlurHash
    this.blurHash: '',

    // Premium
    this.hasPremium: false,
    this.hasVerified: false,

    // Timestamp
    this.timestamp,
    this.timestampBirthday,
  });

  factory FlybisUser.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    if (data == null) {
      logger.i('FlybisUser.fromMap: null');

      return FlybisUser();
    }

    FlybisUser result = FlybisUser(
      // Firebase Auth
      uid: data['uid'] != null ? data['uid'] : documentId,
      email: data['email'] != null ? data['email'] : '',
      photoUrl: data['photoUrl'] != null ? data['photoUrl'] : '',
      displayName: data['displayName'] != null ? data['displayName'] : '',
      displayNameQuery:
          data['displayNameQuery'] != null ? data['displayNameQuery'] : '',

      // Flybis Auth
      username: data['username'] != null ? data['username'] : '',
      usernameQuery: data['usernameQuery'] != null ? data['usernameQuery'] : '',
      bio: data['bio'] != null ? data['bio'] : '',
      bioQuery: data['bioQuery'] != null ? data['bioQuery'] : '',
      bioSentiment: data['bioSentiment'] != null ? data['bioSentiment'] : {},
      bannerUrl: data['bannerUrl'] != null ? data['bannerUrl'] : '',

      // Counts
      followersCount:
          data['followersCount'] != null ? data['followersCount'] : 0,
      followingsCount:
          data['followingsCount'] != null ? data['followingsCount'] : 0,
      friendsCount: data['friendsCount'] != null ? data['friendsCount'] : 0,
      postsCount: data['postsCount'] != null ? data['postsCount'] : 0,

      // BlurHash
      blurHash: data['blurHash'] != null ? data['blurHash'] : '',

      // Premium
      hasPremium: data['hasPremium'] != null ? data['hasPremium'] : false,
      hasVerified: data['hasVerified'] != null ? data['hasVerified'] : false,

      // Timestamp
      timestamp: data['timestamp'] != null ? data['timestamp'] : null,
      timestampBirthday:
          data['timestampBirthday'] != null ? data['timestampBirthday'] : null,
    );

    logger.i('FlybisUser.fromMap: ${result.toMap()}');

    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      // Firebase Auth
      'uid': this.uid,
      'email': this.email,
      'photoUrl': this.photoUrl,
      'displayName': this.displayName,
      'displayNameQuery': this.displayNameQuery,

      // Flybis Auth
      'username': this.username,
      'usernameQuery': this.usernameQuery,
      'bio': this.bio,
      'bioQuery': this.bioQuery,
      'bioSentiment': this.bioSentiment,
      'bannerUrl': this.bannerUrl,

      // Counts
      'followersCount': this.followersCount,
      'followingsCount': this.followingsCount,
      'friendsCount': this.friendsCount,
      'postsCount': this.postsCount,

      // BlurHash
      'blurHash': this.blurHash,

      // Premium
      'hasPremium': this.hasPremium,
      'hasVerified': this.hasVerified,

      // Timestamp
      'timestamp': this.timestamp,
      'timestampBirthday': this.timestampBirthday,
    };
  }
}

class FlybisUserStatus {
  final String? status;
  final dynamic timestamp;

  FlybisUserStatus({
    this.status: 'offline',
    this.timestamp,
  });

  factory FlybisUserStatus.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    if (data == null) {
      return FlybisUserStatus();
    }

    logger.d('FlybisUserStatus.fromMap: ' + data.toString());

    return FlybisUserStatus(
      status: data['status'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'status': this.status,
      'timestamp': this.timestamp,
    };
  }
}
