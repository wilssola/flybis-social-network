// 🎯 Dart imports:
import 'dart:async';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:avatar_glow/avatar_glow.dart';
import 'package:flybis/app/widgets/ad_widget.dart';
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/app/data/models/post_model.dart';
import 'package:flybis/app/data/models/user_model.dart';
import 'package:flybis/plugins/format.dart' as format;
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/app/data/providers/ad_provider.dart' as ad_provider;
import 'package:flybis/app/data/services/follow_service.dart';
import 'package:flybis/app/data/services/friend_service.dart';
import 'package:flybis/app/data/services/post_service.dart';
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/app/views/profile_edit_view.dart' as profile_edit_view;
import 'package:flybis/app/widgets/post_widget.dart' as post_widget;
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;

// � Package imports:
// � Flutter imports:

void openUsername(
  String username,
  Color? pageColor,
) async {
  String? uid = await UserService().getUsername(username.replaceAll('@', ''));

  if (uid != null) {
    Get.to(
      ProfileView(uid: uid, pageColor: pageColor),
    );
  }
}

class ProfileView extends StatefulWidget {
  final String? uid;

  // Page
  final String pageId = 'Profile';
  final Color? pageColor;
  final bool pageHeader;

  // Scaffold
  final GlobalKey<ScaffoldState>? scaffoldKey;

  const ProfileView({
    required this.uid,

    // Page
    this.pageColor,
    this.pageHeader = false,

    // Scaffold
    this.scaffoldKey,
  });

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  //with AutomaticKeepAliveClientMixin<ProfileView> {
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

  FlybisUser user = FlybisUser();
  StreamSubscription? userSubscription;

  String postOrientation = 'grid';

  @override
  initState() {
    super.initState();

    getUser();

    print('username' + Get.parameters['username'].toString());
  }

  getUser() async {
    userSubscription = UserService().streamUser(widget.uid)!.listen((event) {
      if (mounted) {
        setState(() {
          user = event;
        });
      }
    });
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => profile_edit_view.ProfileEditView(
          flybisUserOwner!.uid,
          pageColor: widget.pageColor,
        ),
      ),
    );
  }

  Widget profileButton() {
    bool isOwner = flybisUserOwner!.uid == widget.uid;

    return StreamBuilder(
      stream: FollowService().streamFollowing(widget.uid, flybisUserOwner!.uid),
      builder: (
        BuildContext context,
        AsyncSnapshot<bool> snapshot,
      ) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        bool? isFollowing = snapshot.data;

        if (isOwner) {
          return buildButton(
            text: 'Edit Profile',
            function: editProfile,
            colorButton: widget.pageColor,
            colorText: Colors.white,
          );
        } else if (isFollowing!) {
          return buildButton(
            text: 'Unfollow',
            function: handleUnfollowUser,
            colorButton: Colors.orange,
            colorText: Colors.white,
          );
        } else {
          return buildButton(
            text: 'Follow',
            function: handleFollowUser,
            colorButton: Colors.blue,
            colorText: Colors.white,
          );
        }
      },
    );
  }
  // Profile - End

  Widget followersCount() {
    final String text = 'followers'.tr.toLowerCase();

    final int? count = user.followersCount;

    return countColumn(
      text,
      count,
    );
  }

  Widget followingsCount() {
    final String text = 'followings'.tr.toLowerCase();

    final int? count = user.followingsCount;

    return countColumn(
      text,
      count,
    );
  }

  Widget postsCount() {
    final String text = 'posts'.tr.toLowerCase();

    final int? count = user.postsCount;

    return countColumn(
      text,
      count,
    );
  }

  Widget friendsCount() {
    final String text = 'friends'.tr.toLowerCase();

    final int? count = user.friendsCount;

    return countColumn(
      text,
      count,
    );
  }

  Text textCount(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  // Count - End

  Column countColumn(String label, int? count) {
    return Column(
      children: <Widget>[
        textCount(format.formatCompactNumber(count)),
        Container(
          margin: const EdgeInsets.only(top: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15.0,
              fontWeight: FontWeight.w400,
            ),
          ),
        )
      ],
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
    );
  }

  // Friend
  friendButton() {
    bool isOwner = flybisUserOwner!.uid == widget.uid;

    return StreamBuilder(
      stream: FriendService().streamFriend(widget.uid, flybisUserOwner!.uid),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const Text('');
        }

        bool? isFriend = snapshot.data;

        return StreamBuilder(
          stream: FriendService()
              .streamFriendRequest(flybisUserOwner!.uid, widget.uid),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            if (!snapshot.hasData) {
              return const Text('');
            }

            bool? isRequestedFriendToMe = snapshot.data;

            return StreamBuilder(
              stream: FriendService()
                  .streamFriendRequest(widget.uid, flybisUserOwner!.uid),
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                if (!snapshot.hasData) {
                  return const Text('');
                }

                bool? isRequestedFriend = snapshot.data;

                if (isOwner) {
                  return const Padding(padding: EdgeInsets.zero);
                } else if (!isFriend!) {
                  if (!isRequestedFriendToMe!) {
                    if (isRequestedFriend!) {
                      return buildButton(
                        text: 'Cancel Request',
                        function: handleUnrequestFriendUser,
                        colorButton: Colors.amber,
                        colorText: Colors.white,
                      );
                    } else if (!isRequestedFriend) {
                      return buildButton(
                        text: 'Request Friend',
                        function: handleRequestFriendUser,
                        colorButton: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  } else {
                    return buildButton(
                      text: 'Accept Friend',
                      function: handleFriendUser,
                      colorButton: Colors.green,
                      colorText: Colors.white,
                    );
                  }
                }

                return buildButton(
                  text: 'Remove Friend',
                  function: handleUnfriendUser,
                  colorButton: Colors.red,
                  colorText: Colors.white,
                );
              },
            );
          },
        );
      },
    );
  }

  handleUnrequestFriendUser() {
    FriendService().friendUnrequestUser(flybisUserOwner!.uid, widget.uid);
  }

  handleRequestFriendUser() {
    FriendService().friendRequestUser(widget.uid, flybisUserOwner!.uid);
  }

  handleUnfriendUser() async {
    FriendService().unfriendUser(flybisUserOwner!.uid, widget.uid);

    handleUnrequestFriendUser();
  }

  handleFriendUser() {
    FriendService().friendUser(flybisUserOwner!.uid, widget.uid);
  }
  // Friend - End

  handleFollowUser() {
    FollowService().followUser(widget.uid, flybisUserOwner!.uid);
  }

  handleUnfollowUser() {
    FollowService().unfollowUser(widget.uid, flybisUserOwner!.uid);
  }

  Container buildButton({
    String text = '',
    Function? function,
    Color? colorButton = Colors.white,
    Color colorText = Colors.white,
  }) {
    return Container(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Container(
        width: 150.0,
        height: 35.0,
        alignment: Alignment.center,
        child: MaterialButton(
          onPressed: function as void Function()?,
          color: colorButton,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: colorText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget header() {
    return Padding(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Stack(
            children: <Widget>[
              Positioned(
                //bottom: top + 10,
                left: 0,
                right: 0,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        (!kIsWeb || MediaQuery.of(context).size.width <= 720)
                            ? 250.0
                            : 350,
                    maxHeight:
                        (!kIsWeb || MediaQuery.of(context).size.width <= 720)
                            ? 250.0
                            : 350,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: Container(
                      color: widget.pageColor,
                      height:
                          (!kIsWeb || MediaQuery.of(context).size.width <= 720)
                              ? 250.0
                              : 350,
                      width: MediaQuery.of(context).size.width,
                      child: user.bannerUrl!.isNotEmpty
                          ? ImageNetwork.cachedNetworkImage(
                              imageUrl: user.bannerUrl!,
                              fit: BoxFit.cover,
                              showIconError: false,
                              color: widget.pageColor!,
                              alignment: Alignment.topCenter,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(
                  top: 100,
                  bottom: kNotIsWebOrScreenLittle(context) ? 25 : 50,
                ),
                child: AvatarGlow(
                  glowColor: Colors.white,
                  endRadius: kNotIsWebOrScreenLittle(context) ? 75 : 125.0,
                  repeat: true,
                  showTwoGlows: true,
                  duration: const Duration(milliseconds: 2000),
                  repeatPauseDuration: const Duration(milliseconds: 100),
                  child: Material(
                    elevation: 8.0,
                    shape: const CircleBorder(),
                    child: CircleAvatar(
                      radius: kNotIsWebOrScreenLittle(context) ? 50.0 : 150.0,
                      backgroundColor: Colors.white,
                      backgroundImage: user.photoUrl!.isNotEmpty
                          ? ImageNetwork.cachedNetworkImageProvider(
                              user.photoUrl!,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 10),
            child: user.username!.isNotEmpty
                ? utils_widget.UtilsWidget().usernameText(user.username!)
                : const Text(''),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 5),
            child: Text(
              user.displayName!,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.only(top: 5, bottom: 15),
            child: user.bio!.isNotEmpty
                ? Text(
                    '"' + user.bio! + '"',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  )
                : const Text(''),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        postsCount(),
                        followersCount(),
                        followingsCount(),
                        friendsCount(),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        profileButton(),
                        friendButton(),
                      ],
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget streamPosts() {
    return StreamBuilder(
      stream: PostService().streamPosts(widget.uid, limit),
      builder: (
        BuildContext context,
        AsyncSnapshot<List<FlybisPost>> snapshot,
      ) {
        if (!snapshot.hasData) {
          final Widget loading = Container(
            padding: const EdgeInsets.all(10),
            child: utils_widget.UtilsWidget().circularProgress(
              context,
              color: widget.pageColor,
            ),
          );

          return kNotIsWebOrScreenLittle(context)
              ? loading
              : Card(child: loading);
        }

        List<FlybisPost> posts = [];

        for (var flybisPost in snapshot.data!) {
          posts.add(flybisPost);
        }

        if (posts.isEmpty) {
          final Widget empty =
              utils_widget.UtilsWidget().infoText('Nenhum post encontrado');

          return kNotIsWebOrScreenLittle(context) ? empty : Card(child: empty);
        }

        if (postOrientation == 'grid') {
          List<Widget> gridTiles = [];

          for (var post in posts) {
            gridTiles.add(post_widget.PostWidget(
              key: ValueKey(post.postId),
              flybisPost: post,
              postWidgetType: post_widget.PostWidgetType.GRID,
              pageColor: widget.pageColor,
            ));
          }

          return Container(
            padding: const EdgeInsets.only(top: 10),
            width: kNotIsWebOrScreenLittle(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.5,
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: (kNotIsWebOrScreenLittle(context)) ? 3 : 4,
                childAspectRatio: 1,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
              ),
              itemCount: gridTiles.length,
              itemBuilder: (context, index) {
                return kNotIsWebOrScreenLittle(context)
                    ? gridTiles[index]
                    : Card(child: gridTiles[index]);
              },
              physics: const NeverScrollableScrollPhysics(),
            ),
          );
        } else {
          List<Widget> listTiles = [];

          for (var post in posts) {
            listTiles.add(post_widget.PostWidget(
              key: ValueKey(post.postId),
              flybisPost: post,
              postWidgetType: post_widget.PostWidgetType.LIST,
              pageColor: widget.pageColor,
            ));
          }

          return SizedBox(
            width: kNotIsWebOrScreenLittle(context)
                ? MediaQuery.of(context).size.width
                : MediaQuery.of(context).size.width * 0.5,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: listTiles.length,
              itemBuilder: (context, index) {
                return kNotIsWebOrScreenLittle(context)
                    ? listTiles[index]
                    : Card(child: listTiles[index]);
              },
              physics: const NeverScrollableScrollPhysics(),
            ),
          );
        }
      },
    );
  }

  Widget toggle() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          const Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),
          IconButton(
            onPressed: () => setPostOrientation('grid'),
            icon: Icon(
              Icons.grid_on,
              color: postOrientation == 'grid'
                  ? Theme.of(context).iconTheme.color
                  : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () => setPostOrientation('list'),
            icon: Icon(
              Icons.list,
              color: postOrientation == 'list'
                  ? Theme.of(context).iconTheme.color
                  : Colors.grey,
            ),
          ),
          const Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),
        ],
      ),
    );
  }

  setPostOrientation(String postOrientation) {
    if (mounted) {
      setState(() {
        this.postOrientation = postOrientation;
      });
    }
  }

  Widget profile() {
    final AdWidget adWidget = AdWidget(
      padding: const EdgeInsets.only(top: 10),
      pageId: widget.pageId,
      pageColor: widget.pageColor!,
    );

    return ListView(
      controller: scrollController,
      children: <Widget>[
        header(),
        const Divider(height: 0, thickness: 0),
        toggle(),
        const Divider(height: 0, thickness: 0),
        !kIsWeb
            ? adWidget
            : utils_widget.UtilsWidget().webBody(
                context,
                child: kNotIsWebOrScreenLittle(context)
                    ? adWidget
                    : Card(child: adWidget),
              ),
        !kIsWeb
            ? streamPosts()
            : utils_widget.UtilsWidget().webBody(
                context,
                child: streamPosts(),
              ),
      ],
    );
  }

  @override
  //bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    //super.build(context);

    return Scaffold(
      appBar: utils_widget.UtilsWidget().header(
        context,
        titleText: 'Perfil',
        scaffoldKey: widget.scaffoldKey,
        pageColor: widget.pageColor,
        pageHeader: widget.pageHeader,
      ),
      body: !kIsWeb
          ? profile()
          : Scrollbar(
              thumbVisibility: true,
              showTrackOnHover: true,
              controller: scrollController,
              child: profile(),
            ),
      floatingActionButton: !kNotIsWebOrScreenLittle(context)
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
  }
}

void showProfile(
  BuildContext context, {
  required String? uid,
  Color? pageColor,
}) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProfileView(
        uid: uid,
        pageColor: pageColor,
      ),
    ),
  );
}
