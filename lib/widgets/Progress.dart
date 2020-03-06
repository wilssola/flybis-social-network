import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Container linearProgress(
    {Color valueColor = Colors.black, Color backgroundColor = Colors.white}) {
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
    child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(color)),
    alignment: Alignment(0.0, 0.0),
  );
}

Container centerCircularProgress(
  BuildContext context, {
  Color color = Colors.black,
}) {
  var bodyHeight = !kIsWeb
      ? MediaQuery.of(context)
          .size
          .height /*- (Scaffold.of(context).appBarMaxHeight + 100)*/ : MediaQuery
              .of(context)
          .size
          .height;

  return Container(
    width: MediaQuery.of(context).size.width,
    height: bodyHeight,
    child: circularProgress(
      color: color,
    ),
  );
}
