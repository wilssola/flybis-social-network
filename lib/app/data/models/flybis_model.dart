// 🌎 Project imports:
import 'package:flutter/material.dart';
import 'package:flybis/global.dart';

class FlybisIntroduction {
  String title;
  String image;
  String body;

  FlybisIntroduction({
    required this.title,
    required this.image,
    required this.body,
  });

  factory FlybisIntroduction.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
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

class FlybisView {
  final IconData iconData;
  final Icon icon;
  final String string;
  final Text text;
  final Color color;

  FlybisView({
    required this.iconData,
    required this.icon,
    required this.string,
    required this.text,
    required this.color,
  });

  factory FlybisView.set(IconData iconData, String string, Color color) {
    return FlybisView(
      iconData: iconData,
      icon: Icon(iconData),
      string: string,
      text: Text(string),
      color: color,
    );
  }
}
