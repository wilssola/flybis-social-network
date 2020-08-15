import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flybis/pages/App.dart';

AppBar header(
  final BuildContext context, {
  final GlobalKey<ScaffoldState> scaffoldKey,
  final bool isAppTitle = false,
  final bool removeBackButton = false,
  final String titleText,
  final Color pageColor,
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    elevation: 0,
    leading: scaffoldKey != null
        ? Builder(
            builder: (context) => IconButton(
              icon: Icon(
                Icons.menu,
                color: Theme.of(context).iconTheme.color,
              ),
              onPressed: () => scaffoldKey.currentState.openDrawer(),
            ),
          )
        : null,
    title: Row(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 25),
          child: Text(
            isAppTitle ? 'FLYBIS' : titleText,
            style: TextStyle(
              color: Colors.white,
              fontFamily: isAppTitle ? 'Matiz' : 'Lato-Heavy',
              fontSize: isAppTitle ? 30.0 : 20.0,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Spacer(),
        kIsWeb && scaffoldKey != null
            ? Container(
                height: 50.0,
                width: MediaQuery.of(context).size.width > 1080
                    ? 600
                    : MediaQuery.of(context).size.width > 640
                        ? 400
                        : MediaQuery.of(context).size.width > 480
                            ? 200
                            : MediaQuery.of(context).size.width > 360 ? 100 : 0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: BouncingScrollPhysics(),
                  children: pageButtons,
                ),
              )
            : Padding(padding: EdgeInsets.zero),
      ],
    ),
    centerTitle: false,
    backgroundColor: pageColor != null ? pageColor : Colors.red,
  );
}
