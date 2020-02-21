import 'package:flutter/material.dart';

Container linearProgress() {
  return Container(
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.black),
      backgroundColor: Colors.white,
    ),
  );
}

Container circularProgress({Color color = Colors.black}) {
  return Container(
    color: Colors.white,
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(color),
    ),
    alignment: Alignment(
      0.0,
      0.0,
    ),
  );
}
