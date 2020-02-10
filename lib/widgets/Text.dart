import 'package:flutter/cupertino.dart';

Widget infoText(String text) {
  return Container(
    padding: EdgeInsets.all(15),
    alignment: Alignment.center,
    child: Text(
      text,
      style: TextStyle(
        fontSize: 20,
      ),
    ),
  );
}
