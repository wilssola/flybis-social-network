// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/app/data/models/comment_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/plugins/timeago.dart' deferred as timeago;
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/app/views/profile_view.dart' deferred as profile_view;
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;

Future<bool> loadLibraries() async {
  await profile_view.loadLibrary();
  await timeago.loadLibrary();

  return true;
}

class CommentWidget extends StatelessWidget {
  final FlybisComment? flybisComment;

  const CommentWidget({
    this.flybisComment,
  });

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
          future: UserService().getUser(flybisComment!.userId),
          builder: (
            BuildContext context,
            AsyncSnapshot<FlybisUser?> snapshot,
          ) {
            FlybisUser? flybisUser = FlybisUser();

            if (snapshot.hasData) {
              flybisUser = snapshot.data;
            }

            return Column(
              children: <Widget>[
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: kAvatarBackground,
                    backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      flybisUser!.photoUrl!,
                    ),
                  ),
                  title: GestureDetector(
                    onTap: () => profile_view.showProfile(
                      context,
                      uid: flybisUser!.uid,
                    ),
                    child: utils_widget.UtilsWidget().usernameText(
                      flybisUser.username!,
                    ),
                  ),
                  subtitle: utils_widget.UtilsWidget().selectableText(
                    flybisComment!.commentContent,
                  ),
                  trailing: Text(
                    timeago.timeUntil(
                      flybisComment!.timestamp.toDate(),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
