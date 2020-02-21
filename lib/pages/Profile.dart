import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import "package:flutter_svg/svg.dart";

import "package:flybis/widgets/Ads.dart";
import "package:flybis/widgets/Header.dart";
import "package:flybis/widgets/Progress.dart";
import "package:flybis/widgets/PostTile.dart";
import "package:flybis/widgets/PostWidget.dart";
import "package:flybis/models/User.dart";
import "package:flybis/models/Post.dart";
import "package:flybis/pages/Home.dart";
import "package:flybis/pages/EditProfile.dart";
import 'package:flybis/plugins/format.dart';
import "package:flybis/plugins/image_network/image_network.dart";

import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  final String profileId;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Color pageColor;

  Profile({this.profileId, this.scaffoldKey, this.pageColor});
  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  final String currentUserId = currentUser?.id;
  bool isLoading = false;

  int postCount = 0;
  List<Post> posts = [];
  String postOrientation = "grid";

  int followerCount = 0;
  int followingCount = 0;
  bool isFollowing = false;

  int friendsCount = 0;
  bool isFriend = false;
  bool isRequestedFriend = false;
  bool isRequestedFriendToMe = false;

  bool isLoad = false;

  @override
  void initState() {
    super.initState();
    getProfile();
  }

  // Profile
  getProfile() async {
    await checkIfFriend();
    await checkIfRequestFriend();
    await checkIfRequestFriendToMe();
  }

  editProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfile(
          currentUserId: currentUserId,
          pageColor: widget.pageColor,
        ),
      ),
    );
  }

  buildProfileButton() {
    return FutureBuilder(
      future: followersRef
          .document(widget.profileId)
          .collection("userFollowers")
          .document(currentUserId)
          .get(source: Source.serverAndCache),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return buildButton();
        }

        // Viewing own profile? Should show EditProfile button.
        bool isOwner = currentUserId == widget.profileId;
        bool isFollowing = snapshot.data.exists;

        if (isOwner) {
          return buildButton(
            text: "Edit Profile",
            function: editProfile,
            colorButton: Colors.cyan,
            colorText: Colors.white,
          );
        } else if (isFollowing) {
          return buildButton(
            text: "Unfollow",
            function: handleUnfollowUser,
            colorButton: Colors.orange,
            colorText: Colors.white,
          );
        } else if (!isFollowing) {
          return buildButton(
            text: "Follow",
            function: handleFollowUser,
            colorButton: Colors.blue,
            colorText: Colors.white,
          );
        }

        return null;
      },
    );
  }
  // Profile - End

  // Count
  getFollowing() {
    return futureCount(
      followingRef
          .document(widget.profileId)
          .collection("userFollowing")
          .getDocuments(),
    );
  }

  getPosts() {
    return futureCount(
      postsRef.document(widget.profileId).collection("userPosts").getDocuments(),
    );
  }

  getFollowers() {
    return futureCount(
      followersRef
          .document(widget.profileId)
          .collection("userFollowers")
          .getDocuments(),
    );
  }

  getFriends() {
    return futureCount(
      friendsRef
          .document(widget.profileId)
          .collection("userFriends")
          .getDocuments(),
    );
  }

  FutureBuilder futureCount(Future future) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return textCount("0");
        }

        return textCount(formatCompactNumber(snapshot.data.documents.length));
      },
    );
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

  Column buildCountColumn(String label, Widget count) {
    return Column(
      children: <Widget>[
        count,
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
            text: "Cancel Request",
            function: handleUnrequestFriendUser,
            colorButton: Colors.amber,
            colorText: Colors.white,
          );
        } else if (!isRequestedFriend) {
          return buildButton(
            text: "Request Friend",
            function: handleRequestFriendUser,
            colorButton: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        return buildButton(
          text: "Accept Friend",
          function: handleFriendUser,
          colorButton: Colors.green,
          colorText: Colors.white,
        );
      }
    } else if (isFriend) {
      return buildButton(
        text: "Remove Friend",
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
        .document(widget.profileId)
        .collection("userRequests")
        .document(currentUserId)
        .get(source: Source.serverAndCache)
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
        .collection("userRequests")
        .document(currentUserId)
        .setData({});
  }

  handleUnfriendUser() {
    if (mounted) {
      setState(() {
        isFriend = false;
      });
    }

    friendsRef
        .document(widget.profileId)
        .collection("userFriends")
        .document(currentUserId)
        .get(source: Source.serverAndCache)
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
        .collection("userFriends")
        .document(widget.profileId)
        .setData({});
  }

  checkIfRequestFriend() async {
    DocumentSnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection("userRequests")
        .document(currentUserId).get(source: Source.serverAndCache);

    if (mounted) {
      setState(() {
        isRequestedFriend = doc.exists;
      });
    }
  }

  checkIfRequestFriendToMe() async {
    DocumentSnapshot doc = await friendsRef
        .document(currentUserId)
        .collection("userRequests")
        .document(widget.profileId)
        .get(source: Source.serverAndCache);

    if (mounted) {
      setState(() {
        isRequestedFriendToMe = doc.exists;
      });
    }
  }

  checkIfFriend() async {
    DocumentSnapshot doc = await friendsRef
        .document(widget.profileId)
        .collection("userFriends")
        .document(currentUserId)
        .get(source: Source.serverAndCache);

    if (mounted) {
      setState(() {
        isFriend = doc.exists;
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
        .collection("userFollowers")
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection("userFollowing")
        .document(widget.profileId)
        .setData({});

    // Add activity feed item to notify about new follower
    activityFeedRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .setData({
      "type": "follow",
      "ownerId": widget.profileId,
      "username": currentUser.username,
      "userId": currentUserId,
      "userProfileImg": currentUser.photoUrl,
      "timestamp": FieldValue.serverTimestamp()
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
        .collection("userFollowers")
        .document(currentUserId)
        .get(source: Source.serverAndCache)
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followingRef
        .document(currentUserId)
        .collection("userFollowing")
        .document(widget.profileId)
        .get(source: Source.serverAndCache)
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    activityFeedRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .get(source: Source.serverAndCache)
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  Container buildButton({
    String text = "",
    Function function,
    Color colorButton = Colors.white,
    Color colorText = Colors.white,
  }) {
    return Container(
      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: Container(
        width: 135.0,
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
        if (!snapshot.hasData) {
          return profileHeader();
        }

        if (!snapshot.data.exists) {
          print("Perfil Inexistente");
        }

        User user = User.fromDocument(snapshot.data);

        return profileHeader(
          username: user.username,
          displayName: user.displayName,
          bio: user.bio,
          photoUrl: user.photoUrl,
        );
      },
    );
  }

  Widget profileHeader({
    username = "",
    displayName = "",
    bio = "",
    photoUrl = "",
  }) {
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
                    minHeight: 250.0,
                    maxHeight: 250.0,
                    minWidth: MediaQuery.of(context).size.width,
                  ),
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: ImageNetwork.cachedNetworkImage(
                      alignment: Alignment.topCenter,
                      imageUrl:
                          "https://images.unsplash.com/photo-1436874555419-bb64221c5c1d?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&w=1000&q=80",
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
                    backgroundColor: Colors.grey[200],
                    backgroundImage: ImageNetwork.cachedNetworkImageProvider(
                      photoUrl,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 25),
            child: Text(
              "@" + username,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
                color: Colors.blue,
              ),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5),
            child: Text(
              displayName,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(top: 5, bottom: 15),
            child: bio.length > 0
                ? Text(
                    '"' + bio + '"',
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
                        buildCountColumn("posts", getPosts()),
                        buildCountColumn("followers", getFollowers()),
                        buildCountColumn("following", getFollowing()),
                        buildCountColumn("friends", getFriends()),
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
  }

  buildProfilePosts() {
    return StreamBuilder(
      stream: postsRef
          .document(widget.profileId)
          .collection("userPosts")
          .orderBy("timestamp", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: 100,
            child: circularProgress(),
          );
        }

        List<Post> posts = [];

        snapshot.data.documents.forEach((doc) {
          posts.add(Post.fromDocument(doc));
        });

        if (posts.isEmpty) {
          return Container(
            padding: EdgeInsets.only(top: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SvgPicture.asset("assets/images/no_content.svg", height: 260),
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "No Posts",
                    style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 40.0,
                        fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          );
        }

        if (postOrientation == "grid") {
          List<GridTile> gridTiles = [];
          
          posts.forEach((post) {
            gridTiles.add(GridTile(child: PostTile(post)));
          });

          bannerToList(
            gridTiles,
            10,
            GridTile(child: bannerGrid()),
          );

          return GridView.builder(
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
          );
        } else if (postOrientation == "list") {
          List<Widget> listTiles = [];

          posts.forEach((post) {
            listTiles.add(PostWidget(
              post: post,
              pageColor: widget.pageColor,
            ));
          });

          bannerToList(
            listTiles,
            5,
            bannerMedia(),
          );

          return ListView.builder(
            shrinkWrap: true,
            itemCount: listTiles.length,
            itemBuilder: (context, index) {
              return listTiles[index];
            },
            physics: NeverScrollableScrollPhysics(),
          );
        }

        return null;
      },
    );
  }

  buildTogglePostOrientation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: () => setPostOrientation("grid"),
          icon: Icon(FeatherIcons.grid),
          color: postOrientation == "grid"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        ),
        IconButton(
          onPressed: () => setPostOrientation("list"),
          icon: Icon(FeatherIcons.list),
          color: postOrientation == "list"
              ? Theme.of(context).primaryColor
              : Colors.grey,
        )
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
        Divider(
          height: 1,
        ),
        buildTogglePostOrientation(),
        Divider(
          height: 1,
        ),
        buildProfilePosts(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoad) {
      Future.delayed(Duration(seconds: 1)).then((_) {
        if (mounted) {
          setState(() {
            isLoad = true;
          });
        }
      });
    }

    return Scaffold(
      appBar: header(
        context,
        titleText: "Perfil",
        scaffoldKey: widget.scaffoldKey,
        pageColor: widget.pageColor,
      ),
      body:
          !isLoad ? circularProgress(color: widget.pageColor) : buildProfile(),
    );
  }
}
