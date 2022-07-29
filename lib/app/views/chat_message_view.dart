// 🎯 Dart imports:
import 'dart:async';
import 'dart:math';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:bubble/bubble.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:giphy_picker/giphy_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/values/regexp.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/chat_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/plugins/timestamp.dart';
import 'package:flybis/app/data/services/chat_service.dart';
import 'package:flybis/app/data/services/encryption_service.dart';
import 'package:flybis/app/views/call_view.dart';
import 'package:flybis/app/views/photo_view.dart';
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;

// � Package imports:
// � Flutter imports:

//  Package imports:

class ChatMessageView extends StatefulWidget {
  final FlybisChatStatus? flybisChatStatus;

  final FlybisUser? flybisUserSender;
  final List<FlybisUser?> flybisUserReceivers;

  final Color pageColor;

  const ChatMessageView({
    Key? key,
    this.flybisChatStatus,
    required this.flybisUserSender,
    required this.flybisUserReceivers,
    required this.pageColor,
  }) : super(key: key);

  @override
  State createState() => ChatMessageViewState(
        flybisChatStatus: flybisChatStatus,
      );
}

class ChatMessageViewState extends State<ChatMessageView> {
  // Scroll
  bool toUpButton = false;
  bool showToUpButton = false;
  int limit = 0;
  int oldLimit = 0;
  ScrollController? scrollController;

  scrollInit() {
    scrollController = ScrollController();
    scrollController!.addListener(scrollListener);
  }

  scrollListener() {
    if (scrollController!.offset >=
            scrollController!.position.maxScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = limit + 5;
      });
    }

    if (scrollController!.offset <=
            scrollController!.position.minScrollExtent &&
        !scrollController!.position.outOfRange) {
      setState(() {
        limit = 0;
      });
    }

    listenScrollToUp();
  }

  scrollToUp() {
    hideScrollToUpButton();

    scrollController!.jumpTo(1.0);

    setState(() {
      limit = 0;
    });
  }

  listenScrollToUp() {
    if (scrollController!.offset > scrollController!.position.minScrollExtent) {
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

    Future.delayed(const Duration(milliseconds: 500)).then((value) {
      setState(() {
        showToUpButton = false;
      });
    });
  }
  // Scroll - End

  FlybisChatStatus? flybisChatStatus;

  ChatMessageViewState({
    required this.flybisChatStatus,
  });

  List<FlybisChatMessage>? messagesList;

  PickedFile? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  final ChatService chatService = ChatService();

  @override
  void initState() {
    scrollInit();

    focusNode.addListener(onFocusChange);

    initChat();

    super.initState();
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

  Future<void> initChat() async {
    if (mounted) {
      setState(() {
        isLoading = false;
        isShowSticker = false;
      });
    }

    if (flybisChatStatus == null) {
      chatService
          .streamStatus(checkHasCode(widget.flybisUserSender!.uid,
              widget.flybisUserReceivers[0]!.uid))!
          .listen((event) {
        if (mounted) {
          setState(() {
            flybisChatStatus = event;
          });
        }
      });
    }

    chatService.setStatus(flybisChatStatus!);
    chatService.resetStatusCount(
      chatId: flybisChatStatus!.chatId,
      userId: widget.flybisUserSender!.uid,
    );
  }

  Future<void> initCall() async {
    String callId = await ChatService().addCall(flybisChatStatus!.chatId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallView(
          chat: flybisChatStatus!.chatId,
          callId: callId,
        ),
      ),
    );
  }

  Future getImage() async {
    imageFile = await ImagePicker().getImage(source: ImageSource.gallery);

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
    focusNode.unfocus();

    if (mounted) {
      setState(() {
        isShowSticker = !isShowSticker;
      });
    }

    buildSticker();
  }

  Future uploadFile() async {
    String fileId = const Uuid().v4();

    Reference reference = FirebaseStorage.instance
        .ref()
        .child(flybisUserOwner!.uid + '/messages/images/message_$fileId.jpg');
    UploadTask uploadTask = reference.putData(await imageFile!.readAsBytes());
    TaskSnapshot storageTaskSnapshot = await uploadTask; //.onComplete;

    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      if (mounted) {
        setState(() {
          isLoading = false;
          onSendMessage(downloadUrl, 'image', id: fileId);
        });
      }
    }, onError: (error) {
      Fluttertoast.showToast(msg: 'This file is not an image');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<void> onSendMessage(
    String content,
    String type, {
    String id = '',
  }) async {
    const int kLimit = 5000;

    if (content.trim().isNotEmpty && content.trim().length <= kLimit) {
      textEditingController.clear();

      id = id.isNotEmpty ? id : const Uuid().v4();

      final int color = Random().nextInt(pageColors.length);

      final String encryptedContent = EncryptionService.instance.encryptWithCRC(
        content,
        flybisChatStatus!.chatKey,
      );

      try {
        FlybisChatMessage message = FlybisChatMessage(
          chatId: flybisChatStatus!.chatId,
          userId: widget.flybisUserSender!.uid,
          messageId: id,
          messageContent: encryptedContent,
          messageType: type,
          messageColor: color,
          timestamp: serverTimestamp(),
        );

        chatService.setMessage(message).then((Object value) {
              scrollController!
                  .jumpTo(scrollController!.position.minScrollExtent);
            } as FutureOr Function(void));

        try {
          Map<String?, int> messageCounts = {};
          for (int i = 0; i < flybisChatStatus!.chatUsers.length; i++) {
            if (flybisChatStatus!.chatUsers[i] != flybisUserOwner!.uid) {
              messageCounts[flybisChatStatus!.chatUsers[i]] = flybisChatStatus!
                      .messageCounts![flybisChatStatus!.chatUsers[i]]! +
                  1;
            }
          }

          FlybisChatStatus newFlybisChatStatus = FlybisChatStatus(
            chatId: flybisChatStatus!.chatId,
            chatKey: flybisChatStatus!.chatKey,
            chatType: flybisChatStatus!.chatType,
            chatUsers: flybisChatStatus!.chatUsers,
            messageContent: encryptedContent,
            messageType: type,
            messageColor: color,
            messageCounts: messageCounts,
          );

          chatService.updateStatus(newFlybisChatStatus);
        } catch (error) {
          print(error);
          Fluttertoast.showToast(msg: 'Error to send');
        }
      } catch (error) {
        print(error);
        Fluttertoast.showToast(msg: 'Error to send');
      }
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

  Widget buildItem(
    BuildContext context,
    int index,
    FlybisChatMessage message,
    String content,
  ) {
    final bool isOwner = message.userId == flybisUserOwner!.uid;

    return Row(
      children: [
        // Avatar
        isLastMessageLeft(index) &&
                message.userId == widget.flybisUserReceivers[0]!.uid
            ? Container(
                margin: const EdgeInsets.only(right: 10),
                child: CircleAvatar(
                  backgroundColor: kAvatarBackground,
                  backgroundImage:
                      widget.flybisUserReceivers[0]!.photoUrl!.isNotEmpty
                          ? ImageNetwork.cachedNetworkImageProvider(
                              widget.flybisUserReceivers[0]!.photoUrl!,
                            )
                          : null,
                ),
              )
            : const Padding(padding: EdgeInsets.zero),
        Column(
          children: <Widget>[
            // Message
            Bubble(
              shadowColor: Colors.black,
              nip: isOwner ? BubbleNip.rightTop : BubbleNip.leftTop,
              alignment: isOwner ? Alignment.centerRight : Alignment.centerLeft,
              color: pageColors[message.messageColor!],
              margin: const BubbleEdges.only(top: 15),
              child: Container(
                margin: EdgeInsets.zero,
                constraints: BoxConstraints(
                  maxWidth:
                      (!kIsWeb || MediaQuery.of(context).size.width <= 720)
                          ? MediaQuery.of(context).size.width * 0.6
                          : MediaQuery.of(context).size.width * 0.4,
                ),
                child: Column(
                  crossAxisAlignment: isOwner
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    message.messageType == 'text'
                        // Text
                        ? urlContains(content)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    content,
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  LinkPreview(
                                    text: urlFromString(content)!,
                                    width: MediaQuery.of(context).size.width,
                                    previewData: null,
                                    onPreviewDataFetched: (PreviewData) {},
                                  ),
                                ],
                              )
                            : Text(
                                content,
                                textAlign: TextAlign.left,
                                style: const TextStyle(color: Colors.white),
                              )
                        : message.messageType == 'image'
                            // Image
                            ? GestureDetector(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoView(
                                      url: content,
                                      pageColor: widget.pageColor,
                                    ),
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: content.isNotEmpty
                                      ? ImageNetwork.cachedNetworkImage(
                                          height: (!kIsWeb ||
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width <=
                                                      720)
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.5
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                          imageUrl: content,
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                              )
                            // Sticker
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: content.isNotEmpty
                                    ? ImageNetwork.cachedNetworkImage(
                                        height:
                                            (!kIsWeb ||
                                                    MediaQuery.of(context)
                                                            .size
                                                            .width <=
                                                        720)
                                                ? MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5
                                                : MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                        imageUrl: content,
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                    hour(message.timestamp),
                  ],
                ),
              ),
            ),

            // Time
            (isLastMessageRight(index) && isOwner) ||
                    (isLastMessageLeft(index) && !isOwner)
                ? Container(
                    child: Text(
                      DateFormat('dd MMMM KK:mm').format(
                        message.timestamp.toDate(),
                      ),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12.5,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    margin: const EdgeInsets.only(
                      top: 15,
                    ),
                  )
                : Container()
          ],
          crossAxisAlignment:
              isOwner ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        ),
      ],
      mainAxisAlignment:
          isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
    );
  }

  Widget hour(timestamp) {
    return Container(
      margin: const EdgeInsets.only(top: 7.5),
      child: Text(
        DateFormat('KK:mm').format(
          timestamp.toDate(),
        ),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            messagesList != null &&
            messagesList![index - 1].userId == widget.flybisUserSender!.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            messagesList != null &&
            messagesList![index - 1].userId != widget.flybisUserSender!.uid) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  void buildSticker() async {
    final gif = await (GiphyPicker.pickGif(
      context: context,
      apiKey: '0TH9WzvgjcHUKckMJLnGfrwvLz8DLfqa',
    ) as FutureOr<GiphyGif>);

    if (gif.images.original!.url != null) {
      if (mounted) {
        setState(() {
          isLoading = true;
        });
      }

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            isLoading = false;
            onSendMessage(gif.images.original!.url!, 'giphy');
          });
        }
      });
    }
  }

  Future<bool> onBackPress() {
    Navigator.pop(context);

    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
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
    );
  }

  Widget buildInput() {
    return Material(
      elevation: 8,
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width,
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Row(
          children: <Widget>[
            // Gallery Button
            Material(
              child: Container(
                child: IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.image),
                  onPressed: getImage,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),

            // Giphy Button
            Material(
              child: Container(
                child: IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.gif),
                  onPressed: getSticker,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),

            // Text Input
            Flexible(
              child: Container(
                height: 40,
                padding: EdgeInsets.zero,
                margin: const EdgeInsets.only(left: 5, right: 5),
                child: TextField(
                  maxLines: null,
                  controller: textEditingController,
                  keyboardType:
                      !kIsWeb ? TextInputType.multiline : TextInputType.text,
                  textCapitalization: TextCapitalization.sentences,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: EdgeInsets.only(
                      left: 15,
                      right: 8,
                      bottom: 10,
                    ),
                  ),
                  onSubmitted: (String string) {
                    onSendMessage(textEditingController.text, 'text');
                  },
                  focusNode: focusNode,
                  textAlign: TextAlign.left,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(
                    width: (!kIsWeb || MediaQuery.of(context).size.width <= 720)
                        ? 1
                        : 1.5,
                    color: Theme.of(context).iconTheme.color!,
                  ),
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),

            // Send Button
            Material(
              child: Container(
                child: IconButton(
                  splashRadius: 20,
                  icon: const Icon(Icons.send),
                  onPressed: () => onSendMessage(
                    textEditingController.text,
                    'text',
                  ),
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: flybisChatStatus!.chatId.isEmpty
          ? Center(
              child: utils_widget.UtilsWidget()
                  .circularProgress(context, color: widget.pageColor),
            )
          : StreamBuilder(
              stream:
                  chatService.streamMessages(flybisChatStatus!.chatId, limit),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<FlybisChatMessage>> snapshot,
              ) {
                if (!snapshot.hasData) {
                  return Center(
                    child: utils_widget.UtilsWidget()
                        .circularProgress(context, color: widget.pageColor),
                  );
                } else {
                  messagesList = snapshot.data;

                  return !kIsWeb
                      ? messages(
                          context,
                          snapshot.data!.length,
                          snapshot.data,
                        )
                      : Scrollbar(
                          thumbVisibility: true,
                          showTrackOnHover: true,
                          controller: scrollController,
                          child: messages(
                            context,
                            snapshot.data!.length,
                            snapshot.data,
                          ),
                        );
                }
              },
            ),
    );
  }

  Widget messages(
    BuildContext context,
    int length,
    List<FlybisChatMessage>? docs,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(10.0),
      reverse: true,
      controller: scrollController,
      itemCount: length,
      itemBuilder: (BuildContext context, int index) {
        FlybisChatMessage message = docs![index];

        return buildItem(
          context,
          index,
          message,
          EncryptionService.instance.decryptWithCRC(
              message.messageContent!, flybisChatStatus!.chatKey),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: widget.pageColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: ImageNetwork.cachedNetworkImageProvider(
              widget.flybisUserReceivers[0]!.photoUrl!,
            ),
          ),
          title: Text(
            '@' + widget.flybisUserReceivers[0]!.username!,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            widget.flybisUserReceivers[0]!.displayName!,
            style: const TextStyle(color: Colors.white),
          ),
          trailing: GestureDetector(
            child: const Icon(Icons.phone, color: Colors.white),
            onTap: initCall,
          ),
        ),
      ),
      body: WillPopScope(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                // List of messages
                buildListMessage(),

                // Input content
                buildInput(),
              ],
            ),

            // Loading
            buildLoading()
          ],
        ),
        onWillPop: onBackPress,
      ),
      floatingActionButton: utils_widget.UtilsWidget().floatingButtonUp(
        showToUpButton,
        toUpButton,
        Icons.arrow_downward,
        widget.pageColor,
        scrollToUp,
        'ChatMessageView',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}

String checkHasCode(String? flybisUserSender, String? flybisUserReceivers) {
  String chatId;

  if (flybisUserSender.hashCode <= flybisUserReceivers.hashCode) {
    chatId = '$flybisUserSender-$flybisUserReceivers';
  } else {
    chatId = '$flybisUserReceivers-$flybisUserSender';
  }

  return chatId;
}
