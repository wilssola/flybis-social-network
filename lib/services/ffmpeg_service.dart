// 📦 Package imports:
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:flutter_ffmpeg/log.dart';
import 'package:flutter_ffmpeg/media_information.dart';
import 'package:flutter_ffmpeg/statistics.dart';
import 'package:universal_io/io.dart';

String removeExtension(String path) {
  final str = path.substring(0, path.length - 4);
  return str;
}

String getFileExtension(String fileName) {
  final exploded = fileName.split('.');
  return exploded[exploded.length - 1];
}

class FFmpegService {
  static final FlutterFFmpeg encoder = FlutterFFmpeg();
  static final FlutterFFprobe probe = FlutterFFprobe();
  static final FlutterFFmpegConfig config = FlutterFFmpegConfig();

  static Future<String> encodeHLS(videoPath, outDirPath) async {
    assert(File(videoPath).existsSync());

    final arguments = '-y -i $videoPath ' +
        '-preset ultrafast -g 48 -sc_threshold 0 ' +
        '-map 0:0 -map 0:1 -map 0:0 -map 0:1 ' +
        '-c:v:0 libx264 -b:v:0 2000k ' +
        '-c:v:1 libx264 -b:v:1 365k ' +
        '-c:a copy ' +
        '-var_stream_map "v:0,a:0 v:1,a:1" ' +
        '-master_pl_name master.m3u8 ' +
        '-f hls -hls_time 6 -hls_list_size 0 ' +
        '-hls_segment_filename "$outDirPath/%v_fileSequence_%d.ts" ' +
        '$outDirPath/%v_playlistVariant.m3u8';

    final int rc = await encoder.execute(arguments);
    assert(rc == 0);

    return outDirPath;
  }

  static double getAspectRatio(MediaInformation info) {
    final int width = info
        .getStreams()![0]
        .getAllProperties()['width']; //info['streams'][0]['width'];
    final int height = info
        .getStreams()![0]
        .getAllProperties()['height']; //info['streams'][0]['height'];

    final double aspect = height / width;

    return aspect;
  }

  static Future<String> getThumb(videoPath, width, height) async {
    assert(File(videoPath).existsSync());

    final String outPath = '$videoPath.jpg'.replaceFirst('.mp4', '');
    final arguments =
        '-y -i $videoPath -vframes 1 -an -s ${width}x$height -ss 1 $outPath';

    final int rc = await encoder.execute(arguments);
    assert(rc == 0);
    assert(File(outPath).existsSync());

    return outPath;
  }

  static void enableStatisticsCallback(Function(Statistics) cb) {
    return config.enableStatisticsCallback(cb);
  }

  static Future<void> cancel() async {
    await encoder.cancel();
  }

  static Future<MediaInformation> getMediaInformation(String path) async {
    assert(File(path).existsSync());

    return await probe.getMediaInformation(path);
  }

  static int? getDuration(MediaInformation info) {
    return info.getMediaProperties()!['duration'];
  }

  static void enableLogCallback(
    void Function(Log) logCallback,
  ) {
    config.enableLogCallback(logCallback);
  }
}
