import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

AppBar header(
  final BuildContext context, {
  final GlobalKey<ScaffoldState> scaffoldKey,
  final bool isAppTitle = false,
  final bool removeBackButton = false,
  final String titleText,
  final Color pageColor,
}) {
  return AppBar(
      // automaticallyImplyLeading: removeBackButton ? false : true,

      elevation: 0,
      leading: scaffoldKey != null
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => scaffoldKey.currentState.openDrawer(),
              ),
            )
          : null,
      title: Text(
        isAppTitle ? 'FLYBIS' : titleText,
        style: TextStyle(
          color: Colors.white,
          fontFamily: isAppTitle ? 'Matiz' : 'Lato-Heavy',
          fontSize: isAppTitle ? 30.0 : 20.0,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      centerTitle: !kIsWeb ? true : false,
      backgroundColor: pageColor != null
          ? pageColor
          : Colors.red // Theme.of(context).backgroundColor,

      );
}
