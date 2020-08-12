import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flybis/const.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:uuid/uuid.dart';
import 'package:flybis/views/PhotoView.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e3kit/e3kit.dart';
import 'package:flybis/services/Virgil.dart';

import 'package:flybis/pages/App.dart';

import 'package:giphy_picker/giphy_picker.dart';

import 'package:flutter_feather_icons/flutter_feather_icons.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class ViewChat extends StatelessWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final Color pageColor;
  final User peerUser;

  ViewChat(
      {Key key,
      @required this.peerId,
      @required this.peerAvatar,
      @required this.currentUserId,
      @required this.pageColor,
      @required this.peerUser})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: ImageNetwork.cachedNetworkImageProvider(
              peerUser.photoUrl,
            ),
          ),
          title: Text(
            '@${peerUser.username}',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            peerUser.displayName,
            style: TextStyle(color: Colors.white),
          ),
          trailing: GestureDetector(
            child: Icon(FeatherIcons.phoneCall, color: Colors.white),
          ),
        ),
        centerTitle: true,
        backgroundColor: pageColor,
      ),
      body: ChatScreen(
        peerId: peerId,
        peerAvatar: peerAvatar,
        currentUserId: currentUserId,
        pageColor: pageColor,
        peerUser: peerUser,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String currentUserId;
  final Color pageColor;
  final User peerUser;

  ChatScreen({
    Key key,
    @required this.peerId,
    @required this.peerAvatar,
    @required this.currentUserId,
    @required this.pageColor,
    @required this.peerUser,
  }) : super(key: key);

  @override
  State createState() => new ChatScreenState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        id: currentUserId,
        peerUser: peerUser,
      );
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
    @required this.peerUser,
  });

  String peerId;
  String peerAvatar;
  String id;

  User peerUser;

  var listMessage;
  String groupChatId;
  SharedPreferences prefs;

  File imageFile;
  bool isLoading;
  bool isShowSticker;
  String imageUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

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
      if (mounted) {
        setState(() {
          isShowSticker = false;
        });
      }
    }
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    //id = prefs.getString('id') ?? '';

    groupChatId = checkHasCode(id, peerId);

    messagesRef.document(groupChatId).updateData({
      '${id}MessageCount': 0,
    });

    usersRef.document(id).updateData({'chattingWith': peerId});
    if (mounted) {
      setState(() {});
    }
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }
      uploadFile();
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    if (mounted) {
      setState(() {
        isShowSticker = !isShowSticker;
      });
    }

    buildSticker();
  }

  Future uploadFile() async {
    String fileId = Uuid().v4();

    StorageReference reference = FirebaseStorage.instance
        .ref()
        .child(currentUser.uid + '/messages/images/message_$fileId.jpg');
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      if (mounted) {
        setState(() {
          isLoading = false;
          onSendMessage(imageUrl, 1, customId: fileId);
        });
      }
    }, onError: (err) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }

      Fluttertoast.showToast(msg: 'This file is not an image');
    });
  }

  Future<void> onSendMessage(
    String content,
    int type, {
    String customId,
  }) async {
    // type: 0 = text, 1 = image, 2 = sticker

    if (content.trim() != '') {
      textEditingController.clear();

      // Encrypt Content E3Kit
      /*
      final users = await eThree.findUsers([id, peerId]);
      final encryptedContent = await eThree.encrypt(content, users);
      print('Message Encrypted: ' + encryptedContent);
      */
      // Encrypt Content E3Kit

      var messageId = customId != null ? Uuid().v4() : customId;
      print('Message Id: ' + messageId.toString());

      var documentReference = messagesRef
          .document(groupChatId)
          .collection('userMessages')
          .document(messageId);

      var color = Random().nextInt(pageColors.length);

      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': FieldValue.serverTimestamp(),
            'content': content, //encryptedContent,
            'type': type,
            'color': color
          },
        );
      });

      messagesRef.document(groupChatId).get().then((doc) {
        int peerIdMessageCount = 0;

        if (doc.exists) {
          peerIdMessageCount = doc.data['${peerId}MessageCount'];

          messagesRef.document(groupChatId).updateData({
            'lastMessageContent': content, //encryptedContent,
            'lastMessageType': type,
            'lastMessageTimestamp': FieldValue.serverTimestamp(),
            '${peerId}MessageCount': peerIdMessageCount + 1,
            'lastMessageColor': color
          });
        } else {
          messagesRef.document(groupChatId).setData({
            'lastMessageContent': content, //encryptedContent,
            'lastMessageType': type,
            'lastMessageTimestamp': FieldValue.serverTimestamp(),
            '${peerId}MessageCount': peerIdMessageCount + 1,
            'lastMessageColor': color
          });
        }
      });

      activityFeedRef
          .document(peerId)
          .collection('feedItems')
          .document(messageId)
          .setData({
        'type': 'message',
        'uid': currentUser.uid,
        'username': currentUser.username,
        'photoUrl': currentUser.photoUrl,
        'content': content, //encryptedContent,
        'contentType': type,
        'timestamp': FieldValue.serverTimestamp()
      });

      /*
      listScrollController.jumpTo(
        listScrollController.position.maxScrollExtent,
      );
      */

      listScrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
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

  Future<String> decryptContent(String encryptedContent) async {
    final usersDecrypt = await eThree.findUsers([id]);
    final decryptedContent = await eThree.decrypt(
      encryptedContent,
      usersDecrypt[id],
    );

    return decryptedContent.toString();
  }

  Widget buildItemDecrypted(
    int index,
    DocumentSnapshot document,
    String content,
  ) {
    return FutureBuilder(
      future: decryptContent(content),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          content = '...';
        } else {
          content = snapshot.data;
        }

        return buildItem(index, document, content);
      },
    );
  }

  Widget buildItem(
    int index,
    document,
    String content,
  ) {
    if (document['idFrom'] == id) {
      if (colors[document['content']] == null) {
        colors[document['content']] =
            pageColors[Random().nextInt(pageColors.length)];
      }

      // Right (my message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      document['type'] == 0
                          // Text
                          ? Row(
                              children: <Widget>[
                                Text(
                                  content,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            )
                          : document['type'] == 1
                              // Image
                              ? Container(
                                  child: FlatButton(
                                    child: Material(
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            Container(
                                          child: Padding(
                                            padding: EdgeInsets.zero,
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
                                            Container(
                                          child: Padding(
                                            padding: EdgeInsets.zero,
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
                                        imageUrl: content,
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(
                                          8.0,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ViewPhoto(
                                                    url: content,
                                                    pageColor: widget.pageColor,
                                                  )));
                                    },
                                    padding: EdgeInsets.all(0),
                                  ),
                                  margin: EdgeInsets.only(
                                      bottom: isLastMessageRight(index)
                                          ? 20.0
                                          : 10.0,
                                      right: 10.0),
                                )
                              // Sticker
                              : Container(
                                  child: CachedNetworkImage(
                                    imageUrl: content,
                                    height:
                                        MediaQuery.of(context).size.width * 0.5,
                                    fit: BoxFit.fitWidth,
                                  ),
                                  margin: EdgeInsets.only(
                                    bottom:
                                        isLastMessageRight(index) ? 20.0 : 10.0,
                                    right: 10.0,
                                  ),
                                ),
                      hour(document['timestamp']),
                    ],
                  ),
                  padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                  decoration: BoxDecoration(
                      color: document['color'] != null
                          ? pageColors[document['color']]
                          : pageColors[0],
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),

            // Time
            isLastMessageRight(index)
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
          crossAxisAlignment: CrossAxisAlignment.end,
        ),
      );
    } else {
      // Left (peer message)
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                isLastMessageLeft(index)
                    ? CircleAvatar(
                        backgroundColor: avatarBackground,
                        backgroundImage:
                            ImageNetwork.cachedNetworkImageProvider(
                          widget.peerUser.photoUrl,
                        ),
                      )
                    : Container(width: 40.0),
                document['type'] == 0
                    ? Container(
                        child: Row(
                          children: <Widget>[
                            Text(
                              content,
                              style: TextStyle(color: Colors.white),
                            ),
                            hour(document['timestamp'])
                          ],
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        //width: 200.0,
                        decoration: BoxDecoration(
                            color: document['color'] != null
                                ? pageColors[document['color']]
                                : pageColors[pageColors.length],
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
                                  imageUrl: content,
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
                                      url: content,
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
                              imageUrl: content,
                              width: 150.0,
                              height: 100.0,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                              bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                              right: 10.0,
                            ),
                          ),
              ],
              mainAxisAlignment: MainAxisAlignment.start,
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

  Widget hour(timestamp) {
    return Container(
      alignment: Alignment.bottomRight,
      margin: EdgeInsets.only(left: 12.5, top: 7.5),
      child: Text(
        DateFormat('kk:mm').format(
          timestamp.toDate(),
        ),
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
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
      if (mounted) {
        setState(() {
          isShowSticker = false;
        });
      }
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
              padding: EdgeInsets.all(0),
              height: 42,
              child: TextField(
                controller: textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                textCapitalization: TextCapitalization.sentences,
                style: TextStyle(color: Colors.black, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, right: 8, bottom: 10),
                ),
                focusNode: focusNode,
                textAlign: TextAlign.left,
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
                  .collection('userMessages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(widget.pageColor),
                    ),
                  );
                } else {
                  listMessage = snapshot.data.documents;

                  return Scrollbar(
                    isAlwaysShown: kIsWeb,
                    child: ListView.builder(
                      padding: EdgeInsets.all(10.0),
                      reverse: true,
                      controller: listScrollController,
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (context, index) => buildItem(
                        index,
                        snapshot.data.documents[index],
                        snapshot.data.documents[index]['content'],
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
