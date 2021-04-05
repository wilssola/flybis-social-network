// 🌎 Project imports:
import 'package:flybis/global.dart';

class FlybisIntroduction {
  String title;
  String image;
  String body;

  FlybisIntroduction({
    this.title: '',
    this.image: '',
    this.body: '',
  });

  factory FlybisIntroduction.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    logger.d('FlybisIntroduction.fromMap: ' + data.toString());

    return FlybisIntroduction(
      title: data['title'],
      image: data['image'],
      body: data['body'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': this.title,
      'image': this.image,
      'body': this.body,
    };
  }
}
