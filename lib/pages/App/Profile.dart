import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:flutter_native_admob/flutter_native_admob.dart';
import 'package:flybis/const.dart';

import 'package:flybis/services/Admob.dart';
import 'package:flybis/widgets/Header.dart';
import 'package:flybis/widgets/Progress.dart';
import 'package:flybis/widgets/PostWidget.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/widgets/Utils.dart';
import 'package:flybis/models/Post.dart';
import 'package:flybis/pages/App.dart';
import 'package:flybis/pages/Others/EditProfile.dart';
import 'package:flybis/plugins/format.dart';
import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

class ProfilePage extends StatefulWidget {
  final String profileId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color pageColor;

  ProfilePage({this.profileId, this.scaffoldKey, this.pageColor});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin<ProfilePage> {
  final String currentUserId = currentUser?.uid;

  // Posts
  int postsCount = 0;
  List<Post> postsList = [];
  String postOrientation = 'grid';

  // Follows
  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;

  // Friends
  int friendsCount = 0;
  bool isFriend = false;
  bool isRequestedFriend = false;
  bool isRequestedFriendToMe = false;

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    getProfile();
  }

  // Profile
  Future<void> getProfile() async {
    if (mounted) {
      setState(() {
        postsList = [];
      });
    }

    await getPosts();
    await getFollowers();
    await getFollowing();
    await getFriends();

    await checkIfFollowing();

    await checkIfFriend();
    await checkIfRequestFriend();
    await checkIfRequestFriendToMe();

    if (mounted && !loaded) {
      setState(() {
        loaded = true;
      });
    }

    return null;
  }

  Future checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();

    if (mounted) {
      setState(() {
        isFollowing = doc.exists;
      });
    }
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUser,
          pageColor: widget.pageColor,
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isOwner = currentUserId == widget.profileId;

    if (isOwner) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
        colorButton: Colors.cyan,
        colorText: Colors.white,
      );
    } else if (isFollowing) {
      return buildButton(
        text: 'Unfollow',
        function: handleUnfollowUser,
        colorButton: Colors.orange,
        colorText: Colors.white,
      );
    } else if (!isFollowing) {
      return buildButton(
        text: 'Follow',
        function: handleFollowUser,
        colorButton: Colors.blue,
        colorText: Colors.white,
      );
    }
  }
  // Profile - End

  // Count
  Future getPosts() async {
    QuerySnapshot doc = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .getDocuments();

    List<Post> posts = [];

    doc.documents.forEach((element) {
      posts.add(Post.fromDocument(element));
    });

    if (mounted) {
      setState(() {
        this.postsList = posts;
        this.postsCount = doc.documents.length;
      });
    }
  }

  Future getFollowers() async {
    QuerySnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();

    if (mounted) {
      setState(() {
        followerCount = doc.documents.length;
      });
    }
  }

  Future getFollowing() async {
    QuerySnapshot doc = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();

    if (mounted) {
      setState(() {
        followingCount = doc.documents.length;
      });
    }
  }

  Future getFriends() async {
    QuerySnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .getDocuments();

    if (mounted) {
      setState(() {
        friendsCount = doc.documents.length;
      });
    }
  }

  Text textCount(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 22.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  // Count - End

  Column buildCountColumn(String label, int count) {
    return Column(
      children: <Widget>[
        textCount(formatCompactNumber(count)),
        Container(
          margin: EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            label,
            style: TextStyle(
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
  buildFriendButton() {
    bool isOwner = currentUserId == widget.profileId;
    if (isOwner) {
      return Padding(padding: EdgeInsets.zero);
    } else if (!isFriend) {
      if (!isRequestedFriendToMe) {
        if (isRequestedFriend) {
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
      } else if (isRequestedFriendToMe) {
        return buildButton(
          text: 'Accept Friend',
          function: handleFriendUser,
          colorButton: Colors.green,
          colorText: Colors.white,
        );
      }
    } else if (isFriend) {
      return buildButton(
        text: 'Remove Friend',
        function: handleUnfriendUser,
        colorButton: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  handleUnrequestFriendUser() {
    if (mounted) {
      setState(() {
        isRequestedFriend = false;
      });
    }

    friendsRef
        .document(currentUserId)
        .collection('userRequests')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  handleRequestFriendUser() {
    if (mounted) {
      setState(() {
        isRequestedFriend = true;
      });
    }

    // Make AUTH user follower of ANOTHER user (update THEIR followers collections).
    friendsRef
        .document(widget.profileId)
        .collection('userRequests')
        .document(currentUserId)
        .setData({});
  }

  handleUnfriendUser() async {
    if (mounted) {
      setState(() {
        isFriend = false;
      });
    }

    friendsRef
        .document(currentUserId)
        .collection('userFriends')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    handleUnrequestFriendUser();
  }

  handleFriendUser() {
    if (mounted) {
      setState(() {
        isFriend = true;
      });
    }

    friendsRef
        .document(currentUserId)
        .collection('userFriends')
        .document(widget.profileId)
        .setData({});
    friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .setData({});
  }

  checkIfFriend() async {
    DocumentSnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection('userFriends')
        .document(currentUserId)
        .get();

    if (mounted) {
      setState(() {
        isFriend = doc.exists;
      });
    }
  }

  checkIfRequestFriend() async {
    DocumentSnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection('userRequests')
        .document(currentUserId)
        .get();

    if (mounted) {
      setState(() {
        isRequestedFriend = doc.exists;
      });
    }
  }

  checkIfRequestFriendToMe() async {
    DocumentSnapshot doc = await friendsRef
        .document(currentUserId)
        .collection('userRequests')
        .document(widget.profileId)
        .get();

    if (mounted) {
      setState(() {
        isRequestedFriendToMe = doc.exists;
      });
    }
  }
  // Friend - End

  handleFollowUser() {
    if (mounted) {
      setState(() {
        isFollowing = true;
      });
    }

    // Make AUTH user follower of ANOTHER user (update THEIR followers collections)
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});

    // Add activity feed item to notify about new follower
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'uid': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'photoUrl': currentUser.photoUrl,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  handleUnfollowUser() {
    if (mounted) {
      setState(() {
        isFollowing = false;
      });
    }

    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Container buildButton({
    String text = '',
    Function function,
    Color colorButton = Colors.white,
    Color colorText = Colors.white,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Container(
        width: 150.0,
        height: 35.0,
        alignment: Alignment.center,
        child: FlatButton(
          onPressed: function,
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

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        User user = new User();

        if (snapshot.hasData && snapshot.data.exists) {
          user = User.fromDocument(snapshot.data);
        }

        return Padding(
          padding: EdgeInsets.all(0),
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
                        minHeight: !kIsWeb ? 250.0 : 350,
                        maxHeight: !kIsWeb ? 250.0 : 350,
                        minWidth: MediaQuery.of(context).size.width,
                      ),
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Container(
                          color: widget.pageColor,
                          child: ImageNetwork.cachedNetworkImage(
                            alignment: Alignment.topCenter,
                            imageUrl: user.bannerUrl,
                            showIconError: false,
                            color: widget.pageColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 100, bottom: 25),
                    child: Container(
                      alignment: Alignment.center,
                      child: CircleAvatar(
                        radius: !kIsWeb ? 50.0 : 100.0,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            ImageNetwork.cachedNetworkImageProvider(
                          user.photoUrl,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 25),
                child: usernameText(user.username),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  user.displayName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: EdgeInsets.only(top: 5, bottom: 15),
                child: user.bio.length > 0
                    ? Text(
                        '"' + user.bio + '"',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      )
                    : Padding(
                        padding: EdgeInsets.all(0),
                      ),
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
                            buildCountColumn('posts', postsCount),
                            buildCountColumn('followers', followerCount),
                            buildCountColumn('following', followingCount),
                            buildCountColumn('friends', friendsCount),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            buildProfileButton(),
                            buildFriendButton(),
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
      },
    );
  }

  buildProfilePosts() {
    if (postsList.isEmpty) {
      return Container(
        padding: EdgeInsets.only(top: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Text(
                'No Posts',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 40.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          ],
        ),
      );
    }

    if (postOrientation == 'grid') {
      List<Widget> gridTiles = [];

      postsList.forEach((post) {
        gridTiles.add(PostWidget(
          post,
          PostType.GRID,
          pageColor: widget.pageColor,
        ));
      });

      return Container(
        width: !kIsWeb
            ? MediaQuery.of(context).size.width
            : MediaQuery.of(context).size.width * 0.5,
        child: Column(
          children: <Widget>[
            Admob(
              type: NativeAdmobType.banner,
              height: 100,
              color: widget.pageColor,
            ),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: !kIsWeb ? 3 : 4,
                childAspectRatio: 1,
                mainAxisSpacing: 1.5,
                crossAxisSpacing: 1.5,
              ),
              itemCount: gridTiles.length,
              itemBuilder: (context, index) {
                return gridTiles[index];
              },
              physics: NeverScrollableScrollPhysics(),
            ),
          ],
        ),
      );
    } else if (postOrientation == 'list') {
      List<Widget> listTiles = [];

      postsList.forEach((post) {
        listTiles.add(PostWidget(
          post,
          PostType.LIST,
          pageColor: widget.pageColor,
        ));
      });

      /*bannerToList(
        listTiles,
        2,
        Admob(
          height: 350,
          color: widget.pageColor,
        ),
      );*/

      return ListView.builder(
        shrinkWrap: true,
        itemCount: listTiles.length,
        itemBuilder: (context, index) {
          return listTiles[index];
        },
        physics: NeverScrollableScrollPhysics(),
      );
    }
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),
        GestureDetector(
          onTap: () => setPostOrientation('grid'),
          child: Icon(
            FeatherIcons.grid,
            color: postOrientation == 'grid'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
        GestureDetector(
          onTap: () => setPostOrientation('list'),
          child: Icon(
            FeatherIcons.list,
            color: postOrientation == 'list'
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
        ),
        Padding(padding: EdgeInsets.only(top: 25.0, bottom: 25.0)),
      ],
    );
  }

  setPostOrientation(String postOrientation) {
    if (mounted) {
      setState(() {
        this.postOrientation = postOrientation;
      });
    }
  }

  Widget buildProfile() {
    return ListView(
      children: <Widget>[
        buildProfileHeader(),
        Divider(height: 0, thickness: 0),
        buildTogglePostOrientation(),
        Divider(height: 0, thickness: 0),
        buildProfilePosts(),
      ],
    );
  }

  @override
  bool get wantKeepAlive => !kIsWeb ? true : false;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: header(
        context,
        titleText: 'Perfil',
        scaffoldKey: widget.scaffoldKey,
        pageColor: widget.pageColor,
      ),
      body: loaded
          ? LiquidPullToRefresh(
              onRefresh: getProfile,
              color: widget.pageColor,
              child: buildProfile(),
            )
          : circularProgress(
              context,
              color: widget.pageColor,
            ),
    );
  }
}
