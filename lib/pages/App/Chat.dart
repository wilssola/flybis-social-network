import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/pages/App.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/services/Admob.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:intl/intl.dart';
import 'package:flybis/views/ChatView.dart';
import '../Chat/Settings.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Utils.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/format.dart';

import 'package:flybis/const.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final Color pageColor;
  final scaffoldKey;

  ChatPage({
    Key key,
    @required this.currentUserId,
    this.pageColor,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  ChatState createState() => ChatState(); //currentUserId: currentUserId);
}

class ChatState extends State<ChatPage>
    with AutomaticKeepAliveClientMixin<ChatPage> {
  // Scroll
  bool toUpButton = false;
  bool showToUpButton = false;
  int limit = 0;
  int oldLimit = 0;
  ScrollController scrollController;

  scrollInit() {
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController.offset <= scrollController.position.minScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        limit = 0;
      });
    }

    listenScrollToUp();
    scrollDebug();
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController.jumpTo(1.0);

    setState(() {
      limit = 0;
    });

    scrollDebug();
  }

  listenScrollToUp() {
    if (scrollController.offset > scrollController.position.minScrollExtent) {
      setState(() {
        toUpButton = true;
        showToUpButton = true;
      });
    } else {
      hideScrollToUpButton();
    }
  }

  hideScrollToUpButton() {
    setState(() {
      toUpButton = false;
    });

    Future.delayed(Duration(milliseconds: 500)).then((value) {
      setState(() {
        showToUpButton = false;
      });
    });
  }

  scrollDebug() {
    if (oldLimit != limit && !kReleaseMode) {
      oldLimit = limit;
      toastDebug(limit.toString(), widget.pageColor);
    }
  }
  // Scroll - End

  @override
  void initState() {
    scrollInit();

    super.initState();
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  Widget streamChats() {
    return StreamBuilder(
      stream: friendsRef
          .document(currentUser.uid)
          .collection('userFriends')
          .limit(15 + limit)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress(color: widget.pageColor);
        } else {
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, index) => buildItem(
              context,
              snapshot.data.documents[index],
            ),
          );
        }
      },
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    bool hasMessage = false;

    String peerId = document.documentID;

    return StreamBuilder(
      stream: usersRef.document(peerId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return centerCircularProgress(context, color: widget.pageColor);
        }

        return StreamBuilder(
          stream: messagesRef
              .document(checkHasCode(widget.currentUserId, peerId))
              .snapshots(),
          builder: (context, snapshotMessages) {
            if (!snapshotMessages.hasData) {
              return centerCircularProgress(context, color: widget.pageColor);
            }

            hasMessage = snapshotMessages.data.exists;

            User peerUser = new User.fromDocument(snapshot.data);

            int messageCount = 0;
            String lastMessageContent = '';
            String lastMessageTimestamp = '';
            int lastMessageColor = 0;

            if (hasMessage) {
              messageCount = snapshotMessages
                          .data['${widget.currentUserId}MessageCount'] !=
                      null
                  ? snapshotMessages.data['${widget.currentUserId}MessageCount']
                  : 0;

              lastMessageContent = lastMessageContentFormat(
                snapshotMessages.data['lastMessageType'],
                snapshotMessages.data['lastMessageContent'],
              );

              lastMessageTimestamp =
                  snapshotMessages.data['lastMessageTimestamp'] != null
                      ? lastMessageTimestampFormat(
                          snapshotMessages.data['lastMessageTimestamp'])
                      : '';

              lastMessageColor =
                  snapshotMessages.data['lastMessageColor'] != null
                      ? snapshotMessages.data['lastMessageColor']
                      : widget.pageColor;
            }

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ViewChat(
                      peerId: document.documentID,
                      peerAvatar: peerUser.photoUrl,
                      currentUserId: widget.currentUserId,
                      pageColor: widget.pageColor,
                      peerUser: peerUser,
                    ),
                  ),
                );
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: avatarBackground,
                  backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                    peerUser.photoUrl,
                  ),
                ),
                title: Row(
                  children: <Widget>[
                    usernameText(peerUser.username),
                    Spacer(),
                    messageCount > 0
                        ? Container(
                            width: 20,
                            height: 20,
                            child: CircleAvatar(
                              backgroundColor: pageColors[lastMessageColor],
                              child: Text(
                                messageCount.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Text(''),
                  ],
                ),
                subtitle: Row(
                  children: <Widget>[
                    Container(
                      width: 100,
                      child: Text(
                        lastMessageContent,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w300,
                        ),
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                      ),
                      alignment: Alignment.centerLeft,
                    ),
                    Spacer(),
                    Text(lastMessageTimestamp),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: header(context,
          titleText: 'Chat',
          pageColor: widget.pageColor,
          scaffoldKey: widget.scaffoldKey),
      body: Scrollbar(
        isAlwaysShown: kIsWeb,
        child: ListView(
          controller: scrollController,
          children: [
            Admob(
              type: NativeAdmobType.banner,
              color: widget.pageColor,
            ),
            streamChats(),
            Container(
              height: 75,
              width: MediaQuery.of(context).size.width,
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: showToUpButton && toUpButton ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: showToUpButton || toUpButton
            ? FloatingActionButton(
                elevation: 0,
                backgroundColor: widget.pageColor,
                child: Icon(FeatherIcons.arrowUp, color: Colors.white),
                onPressed: scrollToUp,
              )
            : Padding(padding: EdgeInsets.zero),
      ),
    );
  }
}
