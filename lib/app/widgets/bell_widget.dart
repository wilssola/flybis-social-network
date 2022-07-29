// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/bell_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/timeago.dart' deferred as timeago;
import 'package:flybis/app/data/services/user_service.dart'
    deferred as user_service;
import 'package:flybis/app/views/post_view.dart' deferred as post_view;
import 'package:flybis/app/views/profile_view.dart' deferred as profile_view;
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;

import 'package:flybis/plugins/image_network/image_network.dart'
    deferred as image_network;
import 'package:flybis/app/views/chat_message_view.dart'
    deferred as chat_message_view;

Future<bool> loadLibraries() async {
  await timeago.loadLibrary();
  await image_network.loadLibrary();
  await user_service.loadLibrary();
  await chat_message_view.loadLibrary();
  await post_view.loadLibrary();
  await profile_view.loadLibrary();

  return true;
}

class BellWidget extends StatefulWidget {
  final FlybisBell flybisBell;
  final Color pageColor;

  const BellWidget({
    required this.flybisBell,
    required this.pageColor,
  });

  @override
  _BellWidgetState createState() => _BellWidgetState();
}

class _BellWidgetState extends State<BellWidget> {
  Future<Widget> switchBell(BuildContext context) async {
    Function? trailingOnTap;
    String? trailingImage;
    String bellText;

    FlybisUser? flybisUserSender =
        await user_service.UserService().getUser(widget.flybisBell.senderId);
    FlybisUser? flybisUserReceiver =
        await user_service.UserService().getUser(widget.flybisBell.receiverId);

    switch (widget.flybisBell.bellMode) {
      case 'like':
        trailingOnTap = () => showPost(
              context,
              userId: flybisUserOwner!.uid,
              postId: widget.flybisBell.bellContent.contentId,
            );
        trailingImage = widget.flybisBell.bellContent.contentImage;
        bellText = 'liked your post';
        break;

      case 'follow':
        trailingOnTap = () => profile_view.showProfile(
              context,
              uid: flybisUserReceiver!.uid,
              pageColor: widget.pageColor,
            );
        trailingImage = flybisUserReceiver!.photoUrl;
        bellText = 'followed you';
        break;

      case 'comment':
        trailingOnTap = () => showPost(
              context,
              userId: flybisUserOwner!.uid,
              postId: widget.flybisBell.bellContent.contentId,
            );
        trailingImage = widget.flybisBell.bellContent.contentImage;
        bellText = 'commented: ' + widget.flybisBell.bellContent.contentText;
        break;

      case 'message':
        trailingOnTap = () => Get.to(
              chat_message_view.ChatMessageView(
                flybisUserSender: flybisUserSender,
                flybisUserReceivers: [flybisUserReceiver],
                pageColor: widget.pageColor,
              ),
            );
        trailingImage = flybisUserReceiver!.photoUrl;
        bellText = 'talked you: ' + widget.flybisBell.bellContent.contentText;
        break;

      default:
        bellText = 'Unknown bell ' + widget.flybisBell.bellMode;
        break;
    }

    Widget trailing = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: trailingOnTap!(),
        child: CircleAvatar(
          backgroundColor: kAvatarBackground,
          backgroundImage:
              image_network.ImageNetwork.cachedNetworkImageProvider(
            trailingImage!,
          ),
        ),
      ),
    );

    double kBellTextWidth = !kIsWeb
        ? MediaQuery.of(context).size.width * 0.2
        : MediaQuery.of(context).size.width * 0.1;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: kAvatarBackground,
        backgroundImage: image_network.ImageNetwork.cachedNetworkImageProvider(
          flybisUserSender!.photoUrl!,
        ),
      ),
      title: Row(
        children: <Widget>[
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => profile_view.showProfile(
                context,
                uid: widget.flybisBell.senderId,
                pageColor: widget.pageColor,
              ),
              child: utils_widget.UtilsWidget()
                  .usernameText(flybisUserSender.username!),
            ),
          ),
          SizedBox(
            width: kBellTextWidth,
            child: Text(
              ' ' + bellText,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      subtitle: Text(timeago.timeUntil(widget.flybisBell.timestamp.toDate())),
      trailing: trailing,
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

        return FutureBuilder(
          future: switchBell(context),
          builder: (
            BuildContext context,
            AsyncSnapshot<Widget> snapshot,
          ) {
            if (!snapshot.hasData) {
              return const Text('');
            }

            return snapshot.data!;
          },
        );
      },
    );
  }
}

void showPost(
  BuildContext context, {
  required String userId,
  required String postId,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => post_view.PostView(
        userId: userId,
        postId: postId,
      ),
    ),
  );
}
