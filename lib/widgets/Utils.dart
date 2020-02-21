import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget infoCenterText(String text) {
  return Center(
    child: Container(
      child: Text(text),
    ),
  );
}

showSnackbar(scaffoldKey, String content, {int duration = 4}) {
  final SnackBar snackbar = SnackBar(
    content: Text(content),
    duration: Duration(seconds: duration),
  );
  scaffoldKey.currentState.showSnackBar(snackbar);
}

hideSnackbar(scaffoldKey) {
  scaffoldKey.currentState.hideCurrentSnackBar();
}

removeSnackbar(scaffoldKey) {
  scaffoldKey.currentState.removeCurrentSnackBar();
}
