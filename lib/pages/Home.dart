// Dart
import "dart:developer";
import "dart:async";
import "dart:io";
import "dart:ui";

// Flutter
import "package:flutter/cupertino.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";

// Virgil
import "package:e3kit/e3kit.dart";

// Firebase
import "package:firebase_auth/firebase_auth.dart";
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_storage/firebase_storage.dart";
import "package:firebase_messaging/firebase_messaging.dart";

// Flybis
import "package:flybis/pages/CreateAccount.dart";
import "package:flybis/pages/Chat/Main.dart";
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
import 'package:flutter_phoenix/flutter_phoenix.dart';

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

class Home extends StatefulWidget {
  Home({
    this.onSignedIn,
  });

  final VoidCallback onSignedIn;

  @override
  HomeState createState() => HomeState();
}

enum FormMode { LOGIN, SIGNUP }
enum PageMode { HOME, CHAT }

var pageColors = [
  Colors.red,
  Colors.green,
  Colors.blue,
  Colors.cyan,
  Colors.pink,
  Colors.yellow
];

class HomeState extends State<Home> {
  bool isLoad = false;
  bool isAuth = false;

  int pageIndex = 0;
  PageMode pageMode = PageMode.HOME;
  PageController pageController = PageController();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  // Auth
  String formEmail;
  String formPassword;
  FormMode formMode = FormMode.LOGIN;
  final formKey = GlobalKey<FormState>();
  // Auth - End

  String _errorMessage = "";

  @override
  void initState() {
    super.initState();

    auth.setLanguageCode("pt");
    auth.onAuthStateChanged.listen((user) {
      handleSignIn(user);
    });
  }

  Widget logoText() {
    return new RichText(
      text: TextSpan(
        style: TextStyle(fontFamily: "Matiz", fontSize: 75.0),
        children: <TextSpan>[
          TextSpan(text: "F", style: TextStyle(color: Colors.red)),
          TextSpan(text: "L", style: TextStyle(color: Colors.green)),
          TextSpan(text: "Y", style: TextStyle(color: Colors.blue)),
          TextSpan(text: "S", style: TextStyle(color: Colors.cyan)),
          TextSpan(text: "I", style: TextStyle(color: Colors.pink)),
          TextSpan(text: "T", style: TextStyle(color: Colors.yellow)),
        ],
      ),
    );
  }

  handleSignIn(account) async {
    if (account != null) {
      await createUserInFirestore();

      setState(() {
        isAuth = true;
      });

      configurePushNotifications();

      // initialize E3Kit
      // eThree = Device(currentUser.id);
      // await eThree.initialize();
      // await eThree.register();
    } else {
      setState(() {
        isAuth = false;
      });
    }

    Future.delayed(Duration(seconds: 1)).then((_) {
      setState(() {
        isLoad = true;
      });
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
          print("onMessage: $message \n");

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
    DocumentSnapshot doc =
        await usersRef.document(user.uid).get(source: Source.serverAndCache);

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
          "id": user.uid,
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
        doc = await usersRef.document(user.uid).get(source: Source.serverAndCache);
      }
    }

    currentUser = User.fromDocument(doc);
  }

  onPageChanged(int pageIndex) {
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex) {
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 1),
      curve: Curves.bounceInOut,
    );
  }

  @override
  void dispose() {
    pageController.dispose();

    super.dispose();
  }

  Scaffold buildAuthScreen() {
    return Scaffold(
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
                  stream: usersRef.document(currentUser.id).snapshots(),
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
            profileId: currentUser?.id,
            scaffoldKey: scaffoldKey,
            pageColor: pageColors[3],
          ),
          MainScreen(
            currentUserId: currentUser.id,
            pageColor: pageColors[4],
            scaffoldKey: scaffoldKey,
          ),
          Search(
            pageColor: pageColors[5],
          )
        ],
        controller: pageController,
        onPageChanged: onPageChanged,
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
      ),
      bottomNavigationBar: !kIsWeb
          ? BubbleBottomBar(
              backgroundColor: Colors.white,
              currentIndex: pageIndex,
              onTap: onTap,
              elevation: 0,
              //border: Border(top: BorderSide.none),
              hasNotch: true,
              hasInk: true,
              opacity: 0,
              iconSize: 25,
              //activeColor: pageColors[pageIndex],
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
      Color backgroundColor, IconData icon, String title) {
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

  Scaffold buildUnAuthScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            logoText(),
            Container(
              width: 350,
              child: formWidget(),
            ),
            loginButtonWidget(),
            secondaryButton(),
            errorWidget(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      if (isAuth) {
        return buildAuthScreen();
      } else {
        return buildUnAuthScreen();
      }
    } else {
      return LoadingCircle();
    }
  }

  setColor(int tabIndex) {
    if (tabIndex == 0) {
      return Colors.red;
    } else if (tabIndex == 1) {
      return Colors.blue;
    } else if (tabIndex == 2) {
      return Colors.black;
    } else if (tabIndex == 3) {
      return Colors.green;
    } else if (tabIndex == 4) {
      return Colors.purple;
    }
  }

  showSignupForm() {
    formKey.currentState.reset();
    _errorMessage = "";

    setState(() {
      formMode = FormMode.SIGNUP;
    });
  }

  showLoginForm() {
    formKey.currentState.reset();
    _errorMessage = "";

    setState(() {
      formMode = FormMode.LOGIN;
    });
  }

  _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      isLoad = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (formMode == FormMode.LOGIN) {
          userId = await signIn(formEmail, formPassword);
        } else {
          userId = await signUp(formEmail, formPassword);
        }
        setState(() {
          isLoad = false;
        });
        if (userId.length > 0 && userId != null) {
          widget.onSignedIn();
        }
      } catch (e) {
        setState(() {
          isLoad = false;
          if (!kIsWeb) {
            if (Platform.isIOS) {
              _errorMessage = e.details;
            } else {
              _errorMessage = e.message;
            }
          }
        });
      }
    } else {
      setState(() {
        isLoad = false;
      });
    }
  }

  bool _validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  Widget errorWidget() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
          fontWeight: FontWeight.w300,
        ),
      );
    } else {
      return Container(
        height: 0.0,
        width: 0.0,
      );
    }
  }

  Widget progressWidget() {
    if (isLoad) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget formWidget() {
    return Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          formEmailWidget(),
          formPasswordWidget(),
        ],
      ),
    );
  }

  Widget formEmailWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
          labelText: "Email",
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (value) => value.isEmpty ? "Email cannot be empty" : null,
        onChanged: (value) => formEmail = value.trim(),
      ),
    );
  }

  Widget formPasswordWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
          labelText: "Password",
          fillColor: Colors.white,
          border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(25.0),
            borderSide: new BorderSide(),
          ),
        ),
        validator: (value) => value.isEmpty ? "password-notice-empty" : null,
        onChanged: (value) {
          formPassword = value.trim();
        },
      ),
    );
  }

  Widget loginButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: new MaterialButton(
        elevation: 0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: formMode == FormMode.LOGIN
            ? new Text(
                "signin-btn",
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              )
            : new Text(
                "signup-btn",
                style: new TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
        onPressed: _validateAndSubmit,
        shape: RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(25.0),
        ),
      ),
    );
  }

  Widget secondaryButton() {
    return FlatButton(
      child: formMode == FormMode.LOGIN
          ? new Text(
              "switch-btn-signup",
              style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
              ),
            )
          : new Text(
              "switch-btn-signin",
              style: new TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w300,
              ),
            ),
      onPressed: formMode == FormMode.LOGIN ? showSignupForm : showLoginForm,
    );
  }
}

class LoadingCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.white,
        child: circularProgress(color: Colors.black),
        alignment: Alignment(0.0, 0.0),
      ),
    );
  }
}
