// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flybis/app/widgets/ad_widget.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/chat_model.dart';
import 'package:flybis/app/data/models/document_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/format.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/providers/ad_provider.dart';
import 'package:flybis/app/data/services/chat_service.dart';
import 'package:flybis/app/data/services/encryption_service.dart';
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/app/widgets/utils_widget.dart' deferred as utils_widget;

import 'package:flybis/app/views/chat_message_view.dart'
    deferred as chat_message_view;

Future<bool> loadLibraries() async {
  await chat_message_view.loadLibrary();
  await utils_widget.loadLibrary();

  return true;
}

class ChatView extends StatefulWidget {
  final String pageId = 'Chat';
  final Color pageColor;
  final bool pageHeader;

  final GlobalKey<ScaffoldState> scaffoldKey;

  const ChatView({
    Key? key,
    required this.pageColor,
    this.pageHeader = false,
    required this.scaffoldKey,
  }) : super(key: key);

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView> {
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

    if (kIsWeb && !kScreenLittle(context)) {
      listenScrollToUp();
    }
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

  final ChatService chatService = ChatService();

  @override
  void initState() {
    scrollInit();

    super.initState();
  }

  Widget chat(BuildContext context, FlybisDocument document) {
    Widget contact = StreamBuilder(
      stream: UserService().streamUser(document.documentId),
      builder: (
        BuildContext context,
        AsyncSnapshot<FlybisUser> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Padding(padding: EdgeInsets.zero);
        }

        FlybisUser flybisUserReceiver = snapshot.data!;

        String chatId = chat_message_view.checkHasCode(
          flybisUserOwner!.uid,
          flybisUserReceiver.uid,
        );

        return StreamBuilder(
          stream: chatService.streamStatus(chatId),
          builder: (
            BuildContext context,
            AsyncSnapshot<FlybisChatStatus> snapshot,
          ) {
            FlybisChatStatus? flybisChatStatus = FlybisChatStatus(
              chatId: chatId,
              chatKey: "",
              chatType: "direct",
              chatUsers: [flybisUserOwner!.uid, flybisUserReceiver.uid],
            );

            if (snapshot.hasData) {
              flybisChatStatus = snapshot.data;
            }

            bool hasCount = flybisChatStatus!.messageCounts != null &&
                flybisChatStatus.messageCounts!.isNotEmpty &&
                flybisChatStatus.messageCounts![flybisUserOwner!.uid] != null &&
                flybisChatStatus.messageCounts![flybisUserOwner!.uid]! > 0;

            bool hasContent = flybisChatStatus.messageContent.isNotEmpty;

            bool hasTimestamp = flybisChatStatus.timestamp != null;

            String decryptedContent = EncryptionService.instance.decryptWithCRC(
              flybisChatStatus.messageContent,
              flybisChatStatus.chatKey,
            );

            return MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chat_message_view.ChatMessageView(
                        flybisUserSender: flybisUserOwner,
                        flybisUserReceivers: [
                          flybisUserReceiver,
                        ],
                        flybisChatStatus: flybisChatStatus,
                        pageColor: widget.pageColor,
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kAvatarBackground,
                    backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      flybisUserReceiver.photoUrl!,
                    ),
                  ),
                  title: Row(
                    children: <Widget>[
                      utils_widget.UtilsWidget()
                          .usernameText(flybisUserReceiver.username!),
                      const Spacer(),
                      hasCount
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircleAvatar(
                                backgroundColor:
                                    pageColors[flybisChatStatus.messageColor],
                                child: Text(
                                  flybisChatStatus
                                      .messageCounts![flybisUserOwner!.uid]
                                      .toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            )
                          : const Text(''),
                    ],
                  ),
                  subtitle: Row(
                    children: <Widget>[
                      hasContent
                          ? Container(
                              width: 100,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                decryptedContent,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                            )
                          : Text(
                              flybisUserReceiver.displayName!,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                      const Spacer(),
                      hasTimestamp
                          ? Text(
                              messageTimestampFormat(
                                flybisChatStatus.timestamp,
                              ),
                            )
                          : const Text(''),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return kNotIsWebOrScreenLittle(context) ? contact : Card(child: contact);
  }

  Widget streamChats() {
    return StreamBuilder(
      stream: chatService.streamChats(flybisUserOwner!.uid, limit),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisDocument>> snapshot,
      ) {
        if (!snapshot.hasData) {
          return utils_widget.UtilsWidget().scaffoldCenterCircularProgress(
            context,
            color: widget.pageColor,
          );
        }

        if (snapshot.data!.isEmpty) {
          Widget infoText = utils_widget.UtilsWidget().infoText(
            'Que pena, você ainda não tem nenhum amigo adicionado, faça novas amizades',
          );

          Widget ad = AdWidget(
            pageId: widget.pageId,
            pageColor: widget.pageColor,
          );

          return ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              kNotIsWebOrScreenLittle(context)
                  ? infoText
                  : Card(child: infoText),
              kNotIsWebOrScreenLittle(context) ? ad : Card(child: ad),
            ],
          );
        }

        Widget ad = AdWidget(
          pageId: widget.pageId,
          pageColor: widget.pageColor,
        );

        return ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            kNotIsWebOrScreenLittle(context) ? ad : Card(child: ad),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return chat(context, snapshot.data![index]);
              },
            ),
          ],
        );
      },
    );
  }

  Widget chats() {
    return ListView(
      controller: scrollController,
      children: [
        !kIsWeb
            ? streamChats()
            : utils_widget.UtilsWidget().webBody(context, child: streamChats()),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: loadLibraries(),
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        return Scaffold(
          appBar: utils_widget.UtilsWidget().header(
            context,
            scaffoldKey: widget.scaffoldKey,
            titleText: widget.pageId,
            pageColor: widget.pageColor,
            pageHeader: widget.pageHeader,
          ),
          body: !kIsWeb
              ? chats()
              : Scrollbar(
                  thumbVisibility: true,
                  showTrackOnHover: true,
                  controller: scrollController,
                  child: chats(),
                ),
          floatingActionButton: kIsWeb && !kScreenLittle(context)
              ? utils_widget.UtilsWidget().floatingButtonUp(
                  showToUpButton,
                  toUpButton,
                  Icons.arrow_upward,
                  widget.pageColor,
                  scrollToUp,
                  widget.pageId,
                )
              : null,
        );
      },
    );
  }
}
