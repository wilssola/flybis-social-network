import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flybis/pages/App.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:intl/intl.dart';
import 'package:flybis/widgets/ChatView.dart';
import './Chat/Settings.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Utils.dart';

import 'package:flybis/plugins/timeago.dart';
import 'package:flybis/plugins/format.dart';

import 'package:flybis/const.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Chat extends StatefulWidget {
  final String currentUserId;
  final Color pageColor;
  final scaffoldKey;

  Chat({
    Key key,
    @required this.currentUserId,
    this.pageColor,
    this.scaffoldKey,
  }) : super(key: key);

  @override
  ChatState createState() => ChatState(currentUserId: currentUserId);
}

class ChatState extends State<Chat> with AutomaticKeepAliveClientMixin<Chat> {
  ChatState({
    Key key,
    @required this.currentUserId,
  });

  final String currentUserId;

  bool isLoading = false;
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
  }

  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      //handleSignOut();
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Settings()));
    }
  }

  bool isLoad = false;

  get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context,
          titleText: "Chat",
          pageColor: widget.pageColor,
          scaffoldKey: widget.scaffoldKey),
      body: Stack(
        children: <Widget>[
          // List
          Container(
            child: FutureBuilder(
              future: usersRef.getDocuments(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return circularProgress(color: widget.pageColor);
                } else {
                  return ListView.builder(
                    itemBuilder: (context, index) => buildItem(
                      context,
                      snapshot.data.documents[index],
                    ),
                    itemCount: snapshot.data.documents.length,
                  );
                }
              },
            ),
          ),

          // Loading
          Positioned(
            child: isLoading
                ? Container(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          widget.pageColor,
                        ),
                      ),
                    ),
                    color: Colors.white.withOpacity(0.8),
                  )
                : Container(),
          )
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, DocumentSnapshot document) {
    if (document['id'] == currentUserId) {
      return Container();
    } else {
      String peerId = document.documentID;
      bool isFriend = false;
      bool hasMessage = false;

      return StreamBuilder(
        stream: friendsRef
            .document(currentUserId)
            .collection("userFriends")
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return centerCircularProgress(context, color: widget.pageColor);
          }

          snapshot.data.documents.forEach((doc) {
            isFriend = doc.documentID == document.documentID;
          });

          return StreamBuilder(
            stream: messagesRef
                .document(checkHasCode(currentUserId, peerId))
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return centerCircularProgress(context, color: widget.pageColor);
              }

              hasMessage = snapshot.data.exists;

              if (isFriend || hasMessage) {
                return FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewChat(
                          peerId: document.documentID,
                          peerAvatar: document['photoUrl'],
                          currentUserId: currentUserId,
                          pageColor: widget.pageColor,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: avatarBackground,
                      backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                        document['photoUrl'],
                      ),
                    ),
                    title: Row(
                      children: <Widget>[
                        usernameText(document['username']),
                        Spacer(),
                        StreamBuilder(
                          stream: messagesRef
                              .document(checkHasCode(currentUserId, peerId))
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Text("");
                            } else if (snapshot.data.exists) {
                              int messageCount = snapshot.data[
                                          '${currentUserId}MessageCount'] !=
                                      null
                                  ? snapshot
                                      .data['${currentUserId}MessageCount']
                                  : 0;
                              if (messageCount > 0) {
                                return Text(messageCount.toString());
                              } else {
                                return Text('');
                              }
                            }
                            return Text("");
                          },
                        ),
                      ],
                    ),
                    subtitle: StreamBuilder(
                      stream: messagesRef
                          .document(checkHasCode(currentUserId, peerId))
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return Text("");
                        } else if (snapshot.data.exists) {
                          String lastMessageContent = lastMessageContentFormat(
                            snapshot.data['lastMessageType'],
                            snapshot.data['lastMessageContent'],
                          );

                          return Row(
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
                              Text(
                                snapshot.data['lastMessageTimestamp'] != null
                                    ? lastMessageTimestampFormat(
                                        snapshot.data['lastMessageTimestamp'])
                                    : "",
                              ),
                            ],
                          );
                        }

                        return Text(""); //Text(document['displayName']);
                      },
                    ),
                  ),
                );
              }

              return Padding(padding: EdgeInsets.zero);
            },
          );
        },
      );
    }
  }
}

class Choice {
  const Choice({
    this.title,
    this.icon,
  });

  final String title;
  final IconData icon;
}
