// Dart
import "dart:developer";
import "dart:async";
import "dart:io";
import "dart:ui";

// Flutter
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";

// Virgil
import "package:e3kit/e3kit.dart";

// Firebase
import "package:firebase_auth/firebase_auth.dart";

import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_messaging/firebase_messaging.dart";

// Flybis
import "package:flybis/pages/Register.dart";
import "package:flybis/pages/Chat.dart";
import "package:flybis/pages/Activity.dart";
import "package:flybis/pages/Timeline.dart";
import "package:flybis/pages/Profile.dart";
import "package:flybis/pages/Search.dart";
import "package:flybis/pages/Upload.dart";

import "package:flybis/models/User.dart";

import "package:flybis/widgets/Progress.dart";

import "package:flybis/services/Auth.dart";
import "package:flybis/services/Virgil.dart";

import "package:flybis/plugins/image_network/image_network.dart";
// Flybis - End

// Others
import "package:flutter_feather_icons/flutter_feather_icons.dart";
import "package:bubble_bottom_bar/bubble_bottom_bar.dart";

import 'package:cloud_firestore/cloud_firestore.dart';

import '../widgets/Progress.dart';

import './Login.dart';

// Auth
final FirebaseAuth auth = FirebaseAuth.instance;

// Storage
final StorageReference storageRef = FirebaseStorage.instance.ref();
Future<StorageReference> storageUrlRef(url) async =>
    await FirebaseStorage.instance.getReferenceFromUrl(url);

// Firestore
final CollectionReference usersRef = Firestore.instance.collection("users");
final CollectionReference usernamesRef =
    Firestore.instance.collection("usernames");
final CollectionReference postsRef = Firestore.instance.collection("posts");
final CollectionReference commentsRef =
    Firestore.instance.collection("comments");
final CollectionReference activityFeedRef =
    Firestore.instance.collection("feed");
final CollectionReference followersRef =
    Firestore.instance.collection("followers");
final CollectionReference followingRef =
    Firestore.instance.collection("following");
final CollectionReference friendsRef = Firestore.instance.collection("friends");
final CollectionReference timelineRef =
    Firestore.instance.collection("timeline");
final CollectionReference messagesRef =
    Firestore.instance.collection("messages");

// Messaging
final FirebaseMessaging firebaseMessaging = FirebaseMessaging();

User currentUser;
Device eThree;

class App extends StatefulWidget {
  App();

  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
  bool isLoad = false;
  bool isAuth = false;

  int pageIndex = 0;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    auth.setLanguageCode("pt");
    auth.onAuthStateChanged.listen((user) {
      handleSignIn(user);
    });
  }

  handleSignIn(account) async {
    if (account != null) {
      await createUserInFirestore();
      if (mounted) {
        setState(() {
          isAuth = true;
        });
      }

      configurePushNotifications();

      // initialize E3Kit
      // eThree = Device(currentUser.id);
      // await eThree.initialize();
      // await eThree.register();
    } else {
      if (mounted) {
        setState(() {
          isAuth = false;
        });
      }
    }

    Future.delayed(Duration(seconds: 1)).then((_) {
      if (mounted) {
        setState(() {
          isLoad = true;
        });
      }
    });
  }

  configurePushNotifications() async {
    if (!kIsWeb) {
      final FirebaseUser user = await auth.currentUser();

      if (Platform.isIOS) getiOSPermission();

      firebaseMessaging.getToken().then((token) {
        print("Firebase Messaging Token, $token");

        usersRef.document(user.uid).updateData({
          "androidNotificationToken": token,
        });
      });

      firebaseMessaging.configure(
        onLaunch: (Map<String, dynamic> message) async {},
        onResume: (Map<String, dynamic> message) async {},
        onMessage: (Map<String, dynamic> message) async {
          print("onMessage: $message");

          final String recipientId = message["data"]["recipent"];
          final String body = message["notification"]["body"];

          if (recipientId == user.uid) {
            print("Notification shown");

            SnackBar snackbar = SnackBar(
              content: Text(
                body,
                overflow: TextOverflow.ellipsis,
              ),
            );

            scaffoldKey.currentState.showSnackBar(snackbar);
          } else {
            print("Notification not shown");
          }
        },
      );
    }
  }

  getiOSPermission() {
    firebaseMessaging.requestNotificationPermissions(IosNotificationSettings(
      alert: true,
      badge: true,
      sound: true,
    ));
    firebaseMessaging.onIosSettingsRegistered.listen(
      (settings) => print("Settings registered: $settings"),
    );
  }

  createUserInFirestore() async {
    FirebaseUser user = await auth.currentUser();

    // Check if user already exists in users collection DB, according to his ID
    DocumentSnapshot doc = await usersRef.document(user.uid).get();

    // If the user doesn"t exist, go to CreateAccount page
    if (!doc.exists) {
      final String dataResult = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CreateAccount(user.uid)),
      );

      if (dataResult != null) {
        final dataSplit = dataResult.split("-");

        UserUpdateInfo userUpdate = new UserUpdateInfo();
        userUpdate.displayName = dataSplit[1];
        userUpdate.photoUrl = dataSplit[3];
        user.updateProfile(userUpdate);
        await user.reload();
        user = await auth.currentUser();

        // Get username from createAccount, use it to make new user in usersCollection.
        usersRef.document(user.uid).setData({
          "uid": user.uid,
          "username": dataSplit[0],
          "photoUrl": dataSplit[3],
          "email": user.email,
          "displayName": dataSplit[1],
          "bio": dataSplit[2],
          "bannerUrl": dataSplit[4],
          "timestamp": FieldValue.serverTimestamp(),
        });

        await followersRef
            .document(user.uid)
            .collection("userFollowers")
            .document(user.uid)
            .setData({});
        doc = await usersRef.document(user.uid).get();
      }
    }

    currentUser = User.fromDocument(doc);
  }

  onPageChanged(int pageIndex) {
    if (mounted) {
      setState(() {
        this.pageIndex = pageIndex;
      });
    }
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  Scaffold app() {
    return Scaffold(
      primary: true,
      key: scaffoldKey,
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn"t enough vertical
        // space to fit everything.

        elevation: 0,
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: StreamBuilder(
                  stream: usersRef.document(currentUser.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }

                    User user = User.fromDocument(snapshot.data);

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[200],
                        backgroundImage:
                            ImageNetwork.cachedNetworkImageProvider(
                          user.photoUrl,
                        ),
                      ),
                      title: Text(
                        "@${user.username}",
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        user.displayName,
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }),
              decoration: BoxDecoration(
                color: pageColors[pageIndex],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(FeatherIcons.settings),
                    title: Text("Configurações"),
                  ),
                  ListTile(
                    leading: Icon(FeatherIcons.logOut),
                    title: Text("Sair"),
                    onTap: () async {
                      await signOut(context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: PageView(
        children: <Widget>[
          Timeline(
            currentUser: currentUser,
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[0],
          ),
          Activity(
            pageColor: pageColors[1],
            scaffoldKey: scaffoldKey,
          ),
          Upload(
            currentUser: currentUser,
            pageColor: pageColors[2],
          ),
          Profile(
            profileId: currentUser?.uid,
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[3],
          ),
          Chat(
            currentUserId: currentUser.uid,
            pageColor: pageColors[4],
            scaffoldKey: scaffoldKey,
          ),
          Search(
            pageColor: pageColors[5],
          )
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: !kIsWeb ? ClampingScrollPhysics() : ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
      ),
      bottomNavigationBar: !kIsWeb
          ? BubbleBottomBar(
              backgroundColor: Colors.white,
              currentIndex: pageIndex,
              onTap: onTap,
              elevation: 0,
              hasNotch: true,
              hasInk: true,
              opacity: 0,
              iconSize: 25,
              items: <BubbleBottomBarItem>[
                barItem(pageColors[0], FeatherIcons.home, "Início"),
                barItem(pageColors[1], FeatherIcons.bell, "Sino"),
                barItem(pageColors[2], FeatherIcons.aperture, "Câmera"),
                barItem(pageColors[3], FeatherIcons.user, "Perfil"),
                barItem(pageColors[4], FeatherIcons.messageCircle, "Chat"),
                barItem(pageColors[5], FeatherIcons.search, "Busca"),
              ],
            )
          : null,
    );
  }

  BubbleBottomBarItem barItem(
    Color backgroundColor,
    IconData icon,
    String title,
  ) {
    return BubbleBottomBarItem(
      backgroundColor: backgroundColor,
      icon: Icon(
        icon,
        color: Colors.black,
      ),
      activeIcon: Icon(
        icon,
        color: backgroundColor,
      ),
      title: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      if (isAuth) {
        return WillPopScope(
          child: app(),
          onWillPop: onBackPress,
        );
      } else {
        return Login(pageColors: pageColors);
      }
    } else {
      return centerCircularProgress(context);
    }
  }

  Future<bool> onBackPress() {
    //openDialog();
    return Future.value(false);
  }

  Future<Null> openDialog() async {
    switch (await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding:
                EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
            children: <Widget>[
              Container(
                color: Colors.black,
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
                height: 100.0,
                child: Column(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.exit_to_app,
                        size: 30.0,
                        color: Colors.white,
                      ),
                      margin: EdgeInsets.only(bottom: 10.0),
                    ),
                    Text(
                      'Exit app',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Are you sure to exit app?',
                      style: TextStyle(color: Colors.white70, fontSize: 14.0),
                    ),
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.cancel,
                        color: Colors.black,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'CANCEL',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.black,
                      ),
                      margin: EdgeInsets.only(right: 10.0),
                    ),
                    Text(
                      'YES',
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ],
          );
        })) {
      case 0:
        break;
      case 1:
        exit(0);
        break;
    }
  }
}

PageController pageController = PageController();

List<Icon> pageIcons = [
  Icon(FeatherIcons.home),
  Icon(FeatherIcons.bell),
  Icon(FeatherIcons.aperture),
  Icon(FeatherIcons.user),
  Icon(FeatherIcons.messageCircle),
  Icon(FeatherIcons.search)
];

List<Text> pageTexts = [
  Text("Início"),
  Text("Sino"),
  Text("Câmera"),
  Text("Perfil"),
  Text("Chat"),
  Text("Busca"),
];

List<Color> pageColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.cyan,
  Colors.pink,
  Colors.yellow
];

List<Widget> pageButtons = [
  FlatButton.icon(
    icon: pageIcons[0],
    label: pageTexts[0],
    onPressed: () {
      onTap(0);
    },
    textColor: Colors.white,
  ),
  FlatButton.icon(
    icon: pageIcons[1],
    label: pageTexts[1],
    onPressed: () {
      onTap(1);
    },
    textColor: Colors.white,
  ),
  FlatButton.icon(
    icon: pageIcons[2],
    label: pageTexts[2],
    onPressed: () {
      onTap(2);
    },
    textColor: Colors.white,
  ),
  FlatButton.icon(
    icon: pageIcons[3],
    label: pageTexts[3],
    onPressed: () {
      onTap(3);
    },
    textColor: Colors.white,
  ),
  FlatButton.icon(
    icon: pageIcons[4],
    label: pageTexts[4],
    onPressed: () {
      onTap(4);
    },
    textColor: Colors.white,
  ),
  FlatButton.icon(
    icon: pageIcons[5],
    label: pageTexts[5],
    onPressed: () {
      onTap(5);
    },
    textColor: Colors.white,
  ),
];

onTap(int pageIndex) {
  pageController.animateToPage(
    pageIndex,
    duration: Duration(milliseconds: !kIsWeb ? 100 : 100),
    curve: Curves.bounceInOut,
  );
}