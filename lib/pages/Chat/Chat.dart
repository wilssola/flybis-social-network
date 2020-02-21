import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flybis/widgets/ViewPhoto.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e3kit/e3kit.dart';
import 'package:flybis/services/Virgil.dart';

import 'package:flybis/pages/Home.dart';

import 'package:giphy_picker/giphy_picker.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';

class Chat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final Color pageColor;

  Chat({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.currentUserId,
    @required this.pageColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Chat",
        ),
        centerTitle: true,
        backgroundColor: pageColor,
      ),
      body: new ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
        currentUserId: currentUserId,
        pageColor: pageColor,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final Color pageColor;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.currentUserId,
    @required this.pageColor,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
      peerId: peerId, peerAvatar: peerAvatar, id: currentUserId);
}

checkHasCode(id, peerId) {
  var groupChatId;

  if (id.hashCode <= peerId.hashCode) {
    groupChatId = '$id-$peerId';
  } else {
    groupChatId = '$peerId-$id';
  }

  return groupChatId;
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.id,
  });

  String peerId;
  String peerAvatar;
  String id;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController =
      new TextEditingController();
  final ScrollController listScrollController = new ScrollController();
  final FocusNode focusNode = new FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);

    groupChatId = '';

    isLoading = false;
    isShowSticker = false;
    imageUrl = '';

    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    //id = prefs.getString('id') ?? '';

    groupChatId = checkHasCode(id, peerId);

    usersRef.document(id).updateData({'chattingWith': peerId});

    setState(() {});
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });

    buildSticker();
  }

  Future uploadFile() async {
    String fileName = Uuid().v4();

    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(currentUser.id + "/messages/images/post_$fileName.jpg");
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future<void> onSendMessage(String content, int type) async {
    // type: 0 = text, 1 = image, 2 = sticker

    // Encrypt Content
    //final users = await eThree.findUsers([id, peerId]);
    //final encryptedContent = await eThree.encrypt(content, users);

    if (content.trim() != '') {
      textEditingController.clear();

      var messageId = Uuid().v4();

      var documentReference = messagesRef
          .document(groupChatId)
          .collection("userMessages")
          .document(messageId);

      /*Firestore.instance.runTransaction((transaction) async {
        await transaction.setData(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': FieldValue.serverTimestamp(),
            'content': content, //encryptedContent
            'type': type
          },
        );
      });*/

      documentReference.setData({
        'idFrom': id,
        'idTo': peerId,
        'timestamp': FieldValue.serverTimestamp(),
        'content': content.trim(), //encryptedContent
        'type': type,
        'color': Random().nextInt(pageColors.length)
      });

      messagesRef.document(groupChatId).setData({
        'lastMessageContent': content.trim(),
        'lastMessageType': type,
        'lastMessageTimestamp': FieldValue.serverTimestamp()
      });

      /*messagesRef.document(groupChatId).get().then((doc) {
        int difference =
            doc.data["lastMessageTimestamp"].toDate().millisecondsSinceEpoch -
                DateTime.now().millisecondsSinceEpoch;

        if (difference > 60 * 1000) {
          activityFeedRef
              .document(peerId)
              .collection('feedItems')
              .document(messageId)
              .setData({
            "type": 'comment',
            "username": currentUser.username,
            "userId": currentUser.id,
            "userProfileImg": currentUser.photoUrl,
            "commentData": content,
            "timestamp": FieldValue.serverTimestamp()
          });
        }
      });*/

      activityFeedRef
          .document(peerId)
          .collection('feedItems')
          .document(messageId)
          .setData({
        "type": 'comment',
        "username": currentUser.username,
        "userId": currentUser.id,
        "userProfileImg": currentUser.photoUrl,
        "commentData": content,
        "timestamp": FieldValue.serverTimestamp()
      });

      listScrollController.animateTo(0.0,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  String stripMargin(String s) {
    return s.splitMapJoin(
      RegExp(r'^', multiLine: true),
      onMatch: (_) => '\n',
      onNonMatch: (n) => n.trim(),
    );
  }

  Map colors = {};

  Widget buildItem(int index, document) {
    if (document['idFrom'] == id) {
      if (colors[document['content']] == null) {
        colors[document['content']] =
            pageColors[Random().nextInt(pageColors.length)];
      }

      // Right (my message)
      return Row(
        children: <Widget>[
          document['type'] == 0
              // Text
              ? Container(
                  child: Text(
                    document['content'],
                    style: TextStyle(color: Colors.white),
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  decoration: BoxDecoration(
                      color: document['color'] != null
                          ? pageColors[document['color']]
                          : colors[document['content']],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                )
              : document['type'] == 1
                  // Image
                  ? Container(
                      child: FlatButton(
                        child: Material(
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    widget.pageColor),
                              ),
                              width: 200.0,
                              height: 200.0,
                              padding: EdgeInsets.all(70.0),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                            ),
                            imageUrl: document['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewPhoto(
                                        url: document['content'],
                                        pageColor: widget.pageColor,
                                      )));
                        },
                        padding: EdgeInsets.all(0),
                      ),
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                    )
                  // Sticker
                  : Container(
                      child: CachedNetworkImage(
                          imageUrl: document['content'],
                          height: 100.0,
                          fit: BoxFit.fitHeight),
                      margin: EdgeInsets.only(
                        bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                        right: 10.0,
                      ),
                    ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? Material(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                              strokeWidth: 1.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  widget.pageColor),
                            ),
                            width: 35.0,
                            height: 35.0,
                            padding: EdgeInsets.all(10.0),
                          ),
                          imageUrl: peerAvatar,
                          width: 35.0,
                          height: 35.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(
                          Radius.circular(18.0),
                        ),
                        clipBehavior: Clip.hardEdge,
                      )
                    : Container(width: 35.0),
                document['type'] == 0
                    ? Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              document['content'],
                              style: TextStyle(color: Colors.white),
                            ),
                            hour(document['timestamp'])
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        //width: 200.0,
                        decoration: BoxDecoration(
                            color:
                                pageColors[Random().nextInt(pageColors.length)],
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(left: 10.0),
                      )
                    : document['type'] == 1
                        ? Container(
                            child: FlatButton(
                              child: Material(
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          widget.pageColor),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    padding: EdgeInsets.all(70.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                  ),
                                  imageUrl: document['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                                clipBehavior: Clip.hardEdge,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ViewPhoto(
                                      url: document['content'],
                                      pageColor: widget.pageColor,
                                    ),
                                  ),
                                );
                              },
                              padding: EdgeInsets.all(0),
                            ),
                            margin: EdgeInsets.only(left: 10.0),
                          )
                        : Container(
                            child: CachedNetworkImage(
                              imageUrl: document['content'],
                              width: 150.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                                right: 10.0),
                          ),
              ],
            ),

            // Time
            isLastMessageLeft(index)
                ? Container(
                    child: Text(
                      DateFormat('dd MMM kk:mm')
                          .format(document['timestamp'].toDate()),
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 10.0),
      );
    }
  }

  Widget hour(Timestamp timestamp) {
    return Container(
      margin: EdgeInsets.only(left: 12.5),
      child: Text(
        DateFormat("kk:mm").format(
          timestamp.toDate(),
        ),
      ),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      usersRef.document(id).updateData({'chattingWith': null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Sticker
              //(isShowSticker ? buildSticker() : Container()),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  buildSticker() async {
    final gif = await GiphyPicker.pickGif(
      context: context,
      apiKey: '0TH9WzvgjcHUKckMJLnGfrwvLz8DLfqa',
    );

    onSendMessage(gif.images.original.url, 2);

    /*
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('gif1', 2),
                child: new Image.asset(
                  'images/gif1.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif2', 2),
                child: new Image.asset(
                  'images/gif2.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif3', 2),
                child: new Image.asset(
                  'images/gif3.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('gif4', 2),
                child: new Image.asset(
                  'images/gif4.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif5', 2),
                child: new Image.asset(
                  'images/gif5.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif6', 2),
                child: new Image.asset(
                  'images/gif6.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          Row(
            children: <Widget>[
              FlatButton(
                onPressed: () => onSendMessage('gif7', 2),
                child: new Image.asset(
                  'images/gif7.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif8', 2),
                child: new Image.asset(
                  'images/gif8.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              ),
              FlatButton(
                onPressed: () => onSendMessage('gif9', 2),
                child: new Image.asset(
                  'images/gif9.gif',
                  width: 50.0,
                  height: 50.0,
                  fit: BoxFit.cover,
                ),
              )
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
      decoration: new BoxDecoration(
          border:
              new Border(top: new BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      padding: EdgeInsets.all(5.0),
      height: 180.0,
    );
    */
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(widget.pageColor)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            child: new Container(
              //margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(FeatherIcons.image),
                onPressed: getImage,
                color: Colors.black,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: new Container(
              //margin: new EdgeInsets.symmetric(horizontal: 1.0),
              child: new IconButton(
                icon: new Icon(FeatherIcons.gift),
                onPressed: getSticker,
                color: Colors.black,
              ),
            ),
            color: Colors.white,
          ),

          // Edit text
          Flexible(
            child: Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              padding: EdgeInsets.only(left: 15),
              height: 35,
              child: TextField(
                controller: textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15.0,
                ),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(
                    color: Colors.black,
                  ),
                  border: InputBorder.none,
                ),
                focusNode: focusNode,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.all(width: 1),
                borderRadius: BorderRadius.circular(25.0),
              ),
            ),
          ),

          // Button send message
          Material(
            child: Container(
              child: Transform.rotate(
                angle: 45 * pi / 180,
                child: IconButton(
                  icon: Icon(FeatherIcons.send),
                  onPressed: () => onSendMessage(textEditingController.text, 0),
                  color: Colors.black,
                ),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      color: Colors.white,
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId.length == 0
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(widget.pageColor),
              ),
            )
          : StreamBuilder(
              stream: messagesRef
                  .document(groupChatId)
                  .collection("userMessages")
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(widget.pageColor)));
                } else {
                  listMessage = snapshot.data.documents;

                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(index, snapshot.data.documents[index]),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
