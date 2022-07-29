// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/timestamp.dart';

class FlybisPost {
  // User
  final String? userId;

  // Post
  final String? postId;
  final String? postTitle;
  final String? postLocation;
  final String postDescription;
  final List<FlybisPostContent>? postContents;
  final bool postValidity;
  final double? postPopularity;
  final List<dynamic>? postUrls;
  final List<dynamic>? postTags;
  final List<dynamic>? postMentions;

  // Likes
  final int likesCount;

  // Dislikes
  final int dislikesCount;

  // Timestamp
  dynamic timestamp;
  final dynamic timestampDuration;
  final dynamic timestampPopularity;

  FlybisPost({
    // User
    this.userId = '',

    // Post
    this.postId = '',
    this.postTitle = '',
    this.postLocation = '',
    this.postDescription = '',
    this.postContents,
    this.postValidity = false,
    this.postPopularity = 0,
    this.postUrls,
    this.postTags,
    this.postMentions,

    // Likes
    this.likesCount = 0,

    // Dislikes
    this.dislikesCount = 0,

    // Timestamp
    this.timestamp,
    this.timestampDuration,
    this.timestampPopularity,
  });

  factory FlybisPost.fromMap(
    Map<String, dynamic>? data,
    String documentId,
  ) {
    try {
      if (data == null) {
        return FlybisPost();
      }

      logger.i('FlybisPost.fromMap: ' + data.toString());

      List<FlybisPostContent> postContents = [];

      if (data['postContents'] != null) {
        data['postContents'].forEach((content) {
          postContents.add(FlybisPostContent.fromMap(content));
        });
      }

      return FlybisPost(
        // User
        userId: data['userId'] ?? '',

        // Post
        postId: data['postId'] ?? documentId,
        postTitle: data['postTitle'] ?? '',
        postLocation: data['postLocation'] ?? '',
        postDescription: data['postDescription'] ?? '',
        postContents: postContents,
        postValidity: data['postValidity'] ?? false,
        postPopularity: data['postPopularity'] != null
            ? data['postPopularity'].toDouble()
            : 0,
        postUrls: data['postUrls'] ?? [],
        postTags: data['postTags'] ?? [],
        postMentions: data['postMentions'] ?? [],

        // Likes
        likesCount: data['likesCount'] ?? 0,

        // Dislikes
        dislikesCount: data['dislikesCount'] ?? 0,

        // Timestamp
        timestamp: data['timestamp'] ?? timestampNow(),
        timestampDuration: data['timestampDuration'] ?? timestampNow(),
        timestampPopularity: data['timestampPopularity'] ?? timestampNow(),
      );
    } catch (error) {
      logger.e('FlybisPost.fromMap: ' + error.toString());

      return FlybisPost();
    }
  }

  Map<String, dynamic>? toMap() {
    try {
      List<Map<String, dynamic>?> postContents = [];
      if (this.postContents != null) {
        for (var content in this.postContents!) {
          postContents.add(content.toMap());
        }
      }

      return {
        // User
        'userId': userId ?? '',

        // Post
        'postId': postId ?? '',
        'postTitle': postTitle ?? '',
        'postLocation': postLocation ?? '',
        'postDescription': postDescription,
        'postContents': postContents,
        'postValidity': postValidity,
        'postPopularity': postPopularity ?? 0,
        'postUrls': postUrls ?? [],
        'postTags': postTags ?? [],
        'postMentions': postMentions ?? [],

        // Likes
        'likesCount': likesCount,

        // Dislikes
        'dislikesCount': dislikesCount,

        // Timestamp
        'timestamp': timestamp,
        'timestampDuration': timestampDuration,
        'timestampPopularity': timestampPopularity,
      };
    } catch (error) {
      logger.e('FlybisPost.toMap: ' + error.toString());

      return null;
    }
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
    final endTimestamp = FlybisPost.checkTimestamp(duration, popularity);

    final nowTimestamp = DateTime.now().millisecondsSinceEpoch;

    final differenceTimestamp = endTimestamp - nowTimestamp;

    return differenceTimestamp > 0;
  }
}

class FlybisPostContent {
  // Content
  final String? contentId;
  final String? contentUrl;
  final String? contentType; // text, image, video
  final String? contentThumbnail;
  final double? contentAspectRatio;

  // BlurHash
  final String? blurHash;

  // Process
  final bool? hasProcessed;

  FlybisPostContent({
    // Content
    this.contentId = '',
    this.contentUrl = '',
    this.contentThumbnail = '',
    this.contentType = '',
    this.contentAspectRatio = 0,

    // BlurHash
    this.blurHash = '',

    // Process
    this.hasProcessed = false,
  });

  factory FlybisPostContent.fromMap(
    Map<String, dynamic>? data,
  ) {
    try {
      if (data == null) {
        return FlybisPostContent();
      }

      logger.d('FlybisPostContent.fromMap: ' + data.toString());

      return FlybisPostContent(
        // Content
        contentId: data['contentId'] ?? '',
        contentUrl: data['contentUrl'] ?? '',
        contentThumbnail:
            data['contentThumbnail'] ?? '',
        contentType: data['contentType'] ?? '',
        contentAspectRatio: data['contentAspectRatio'] != null
            ? data['contentAspectRatio'].toDouble()
            : 0,

        // BlurHash
        blurHash: data['blurHash'] ?? '',

        // Process
        hasProcessed:
            data['hasProcessed'] ?? false,
      );
    } catch (error) {
      logger.e('FlybisPostContent.fromMap: ' + error.toString());

      return FlybisPostContent();
    }
  }

  Map<String, dynamic>? toMap() {
    try {
      return {
        // Content
        'contentId': contentId,
        'contentUrl': contentUrl,
        'contentThumbnail': contentThumbnail,
        'contentType': contentType,
        'contentAspectRatio': contentAspectRatio,

        // BlurHash
        'blurHash': blurHash,

        // Process
        'hasProcessed': hasProcessed,
      };
    } catch (error) {
      logger.e('FlybisPostContent.toMap: ' + error.toString());

      return null;
    }
  }
}
