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
    this.uid = '',
    this.email = '',
    this.photoUrl = '',
    this.displayName = '',
    this.displayNameQuery = '',

    // Flybis Auth
    this.username = '',
    this.usernameQuery = '',
    this.bio = '',
    this.bioQuery = '',
    this.bioSentiment,
    this.bannerUrl = '',

    // Counts
    this.followersCount = 0,
    this.followingsCount = 0,
    this.friendsCount = 0,
    this.postsCount = 0,

    // BlurHash
    this.blurHash = '',

    // Premium
    this.hasPremium = false,
    this.hasVerified = false,

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
      uid: data['uid'] ?? documentId,
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      displayName: data['displayName'] ?? '',
      displayNameQuery:
          data['displayNameQuery'] ?? '',

      // Flybis Auth
      username: data['username'] ?? '',
      usernameQuery: data['usernameQuery'] ?? '',
      bio: data['bio'] ?? '',
      bioQuery: data['bioQuery'] ?? '',
      bioSentiment: data['bioSentiment'] ?? {},
      bannerUrl: data['bannerUrl'] ?? '',

      // Counts
      followersCount:
          data['followersCount'] ?? 0,
      followingsCount:
          data['followingsCount'] ?? 0,
      friendsCount: data['friendsCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,

      // BlurHash
      blurHash: data['blurHash'] ?? '',

      // Premium
      hasPremium: data['hasPremium'] ?? false,
      hasVerified: data['hasVerified'] ?? false,

      // Timestamp
      timestamp: data['timestamp'],
      timestampBirthday:
          data['timestampBirthday'],
    );

    logger.i('FlybisUser.fromMap: ${result.toMap()}');

    return result;
  }

  Map<String, dynamic> toMap() {
    return {
      // Firebase Auth
      'uid': uid,
      'email': email,
      'photoUrl': photoUrl,
      'displayName': displayName,
      'displayNameQuery': displayNameQuery,

      // Flybis Auth
      'username': username,
      'usernameQuery': usernameQuery,
      'bio': bio,
      'bioQuery': bioQuery,
      'bioSentiment': bioSentiment,
      'bannerUrl': bannerUrl,

      // Counts
      'followersCount': followersCount,
      'followingsCount': followingsCount,
      'friendsCount': friendsCount,
      'postsCount': postsCount,

      // BlurHash
      'blurHash': blurHash,

      // Premium
      'hasPremium': hasPremium,
      'hasVerified': hasVerified,

      // Timestamp
      'timestamp': timestamp,
      'timestampBirthday': timestampBirthday,
    };
  }
}

class FlybisUserStatus {
  final String? status;
  final dynamic timestamp;

  FlybisUserStatus({
    this.status = 'offline',
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
      'status': status,
      'timestamp': timestamp,
    };
  }
}
