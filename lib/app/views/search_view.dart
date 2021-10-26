// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/format.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/services/search_service.dart';
import 'package:flybis/app/views/profile_view.dart';
import 'package:flybis/app/widgets/post_widget.dart';
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;

void openQuery(String searchQuery, Color? pageColor) {
  Get.to(
    SearchView(
      searchQuery: searchQuery,
      pageColor: pageColor,
    ),
  );
}

class SearchView extends StatefulWidget {
  final String pageId = 'Search';
  final Color? pageColor;
  final bool pageHeader;

  final String? searchQuery;

  SearchView({
    this.searchQuery,
    this.pageColor,
    this.pageHeader = false,
  });

  @override
  _SearchViewState createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView>
    with AutomaticKeepAliveClientMixin<SearchView> {
  TextEditingController controller = TextEditingController();
  List<Widget> results = [];
  List<String?> uids = [];
  int limit = 25;

  @override
  void initState() {
    super.initState();

    if (widget.searchQuery != null) {
      search(widget.searchQuery!);
    }
  }

  void search(String text) async {
    if (mounted) {
      setState(() {
        this.results = [];
      });
    }

    uids.clear();

    controller.text = text;

    String query = text.toLowerCase();

    if (query.length > 0) {
      if (!GetUtils.isEmail(query)) {
        if (!query.contains('#')) {
          String username = query.replaceAll('@', '');

          if (!GetUtils.isUsername(username)) {
            List<FlybisUser>? usersByDisplayName =
                await SearchService().getUserByDisplayName(username, limit);

            addUserWidget(usersByDisplayName, uids);
          } else {
            List<FlybisUser>? usersByUsernameLowercase =
                await SearchService().getUserByDisplayName(username, limit);

            addUserWidget(usersByUsernameLowercase, uids);
          }
        }

        List<FlybisUser>? usersByBio =
            await SearchService().getUserByDisplayName(query, limit);

        addUserWidget(usersByBio, uids);
      } else {
        List<FlybisUser>? usersByEmail =
            await SearchService().getUserByDisplayName(query, limit);

        addUserWidget(usersByEmail, uids);
      }

      /*
      QuerySnapshot posts = await postsRef.get();
      posts.docs.forEach((DocumentSnapshot doc) async {
        QuerySnapshot tag = await postsRef
            .doc(doc.id)
            .collection('posts')
            .where('tags', arrayContains: query)
            .limit(5)
            .get();
        addPostWidget(tag);

        QuerySnapshot mention = await postsRef
            .doc(doc.id)
            .collection('posts')
            .where('mentions', arrayContains: query)
            .limit(5)
            .get();
        addPostWidget(mention);
      });
      */
    }
  }

  void addUserWidget(List<FlybisUser>? users, List<String?> uids) {
    if (users != null && users.length > 0) {
      users.forEach((FlybisUser flybisUser) {
        if (flybisUser != null) {
          if (!uids.contains(flybisUser.uid)) {
            uids.add(flybisUser.uid);

            UserResult userResult = UserResult(
              user: flybisUser,
              pageColor: widget.pageColor,
            );

            if (mounted) {
              setState(() {
                this.results.add(userResult);
              });
            }
          }
        }
      });
    }
  }

  void addPostWidget(QuerySnapshot snapshot, List<String?> ids) {
    if (snapshot.docs.isNotEmpty) {
      snapshot.docs.forEach((DocumentSnapshot doc) {
        if (doc.exists) {
          final FlybisPost flybisPost = FlybisPost(); //.fromDocument(doc);

          if (!ids.contains(flybisPost.postId)) {
            ids.add(flybisPost.postId);

            PostWidget postWidget = PostWidget(
              key: ValueKey(flybisPost.postId),
              flybisPost: flybisPost,
              postWidgetType: PostWidgetType.LIST,
              pageColor: widget.pageColor,
            );

            if (mounted) {
              setState(() {
                this.results.add(postWidget);
              });
            }
          }
        }
      });
    }
  }

  void clear() {
    if (mounted) {
      setState(() {
        this.results = [];
      });
    }

    controller.clear();
  }

  Widget form() {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: widget.pageColor,
      title: TextFormField(
        controller: controller,
        onFieldSubmitted: search,
        cursorColor: Colors.white,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar...',
          hintStyle: TextStyle(color: Colors.white),
          border: InputBorder.none,
          filled: false,
          fillColor: Colors.white,
          focusColor: Colors.white,
          hoverColor: Colors.white,
          prefixIcon: Icon(Icons.search, color: Colors.white),
          suffixIcon: IconButton(
            onPressed: clear,
            icon: Icon(Icons.clear, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget listDefault() {
    return Container();
  }

  Widget listResults() {
    return ListView(
      children: [
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: results.length,
          itemBuilder: (BuildContext context, int index) {
            if (results.length == 0) {
              return utils_widget.UtilsWidget().infoText(
                'Nenhum resultado encontrado',
              );
            }

            return results[index];
          },
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: form() as PreferredSizeWidget?,
      body: results.isEmpty ? listDefault() : listResults(),
    );
  }
}

class UserResult extends StatelessWidget {
  final FlybisUser user;

  final Color? pageColor;

  UserResult({
    required this.user,
    required this.pageColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showProfile(
            context,
            uid: user.uid,
            pageColor: pageColor,
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: kAvatarBackground,
              backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                user.photoUrl!,
              ),
            ),
            title: Row(
              children: <Widget>[
                utils_widget.UtilsWidget().usernameText(user.username!),
                Spacer(),
                Text(
                  formatCompactNumber(user.followersCount) + ' followers',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            subtitle: Text(user.displayName!),
          ),
        ),
      ),
    );
  }
}
