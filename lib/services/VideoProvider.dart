import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flybis/models/VideoInfo.dart';

class VideoProvider {
  static saveVideo(VideoInfo video) async {
    await Firestore.instance.collection('videos').document().setData({
        'contentUrl': video.contentUrl,
        'thumbUrl': video.thumbUrl,
        'coverUrl': video.coverUrl,
        'aspectRatio': video.aspectRatio,
        //'uploadedAt': video.uploadedAt,
        'fileName': video.fileName,
      });
  }

  static listenToVideos(callback) async {
    Firestore.instance.collection('videos').snapshots().listen((qs) {
      final videos = mapQueryToVideoInfo(qs);
      callback(videos);
    });
  }

  static mapQueryToVideoInfo(QuerySnapshot qs) {
    return qs.documents.map((DocumentSnapshot ds) {
      return VideoInfo(
        contentUrl: ds.data['contentUrl'],
        thumbUrl: ds.data['thumbUrl'],
        coverUrl: ds.data['coverUrl'],
        aspectRatio: ds.data['aspectRatio'],
        fileName: ds.data['fileName'],
        //uploadedAt: ds.data['uploadedAt'],
      );
    }).toList();
  }
}