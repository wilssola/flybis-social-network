import 'dart:io';

import "package:flutter/material.dart";

import "package:flutter/foundation.dart";

import 'package:flybis/pages/App.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/widgets/Profile.dart';
import 'package:flybis/widgets/Progress.dart';

import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:flybis/services/Auth.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fluttertoast/fluttertoast.dart';

import '../const.dart';

class EditProfile extends StatefulWidget {
  final User currentUser;
  final Color pageColor;
  final Profile profile = new Profile();

  EditProfile(
    this.currentUser, {
    this.pageColor,
  });

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  bool isLoading = false;

  User user;

  bool _bioValid = true;
  bool _displayNameValid = true;

  // Photo
  File photoFile;
  String photoUrl = "";

  // Banner
  File bannerFile;
  String bannerUrl = "";

  photoFromGallery() async {
    var result = await widget.profile.photoGallery(
        widget.currentUser.uid, "photo-${widget.currentUser.uid}");

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  photoFromCamera() async {
    var result = await widget.profile
        .photoCamera(widget.currentUser.uid, "photo-${widget.currentUser.uid}");

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  bannerFromGallery() async {
    var result = await widget.profile.photoGallery(
        widget.currentUser.uid, "banner-${widget.currentUser.uid}");

    if (mounted) {
      setState(() {
        bannerFile = result;
      });
    }
  }

  bannerFromCamera() async {
    var result = await widget.profile.photoCamera(
        widget.currentUser.uid, "banner-${widget.currentUser.uid}");

    if (mounted) {
      setState(() {
        bannerFile = result;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    DocumentSnapshot doc =
        await usersRef.document(widget.currentUser.uid).get();

    user = User.fromDocument(doc);

    displayNameController.text = user.displayName;
    bioController.text = user.bio;

    if (mounted) {
      setState(() {
        photoUrl = user.photoUrl;
        bannerUrl = user.bannerUrl;
        isLoading = false;
      });
    }
  }

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Display Name',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: displayNameController,
          decoration: InputDecoration(
              hintText: 'Update display name',
              errorText: _displayNameValid ? null : 'Display name too short'),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Bio',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: bioController,
          decoration: InputDecoration(
            hintText: 'Update bio',
            errorText: _bioValid ? null : 'Bio too long',
          ),
        )
      ],
    );
  }

  updateProfileData() {
    if (mounted) {
      setState(() {
        displayNameController.text.trim().length < 3 ||
                displayNameController.text.isEmpty
            ? _displayNameValid = false
            : _displayNameValid = true;

        bioController.text.trim().length > 100
            ? _bioValid = false
            : _bioValid = true;

        if (_displayNameValid && _bioValid) {
          usersRef.document(widget.currentUser.uid).updateData({
            'displayName': displayNameController.text,
            'bio': bioController.text
          });
        }
      });
    }

    Fluttertoast.showToast(msg: "Profile updated");
  }

  logout() async {
    await signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: widget.pageColor,
        title: Text('Edit Profile'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done),
            onPressed: () {
              updateProfileData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? circularProgress(color: widget.pageColor)
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: bannerFromCamera,
                            child: Container(
                              color: Colors.black,
                              height: 200,
                              width: MediaQuery.of(context).size.width,
                              child: FittedBox(
                                fit: BoxFit.cover,
                                child: bannerFile == null
                                    ? ImageNetwork.cachedNetworkImage(
                                        imageUrl: bannerUrl,
                                      )
                                    : Image.file(bannerFile),
                              ),
                            ),
                          ),
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 25.0),
                              child: GestureDetector(
                                onTap: photoFromCamera,
                                child: Container(
                                  width: 150,
                                  height: 150,
                                  child: CircleAvatar(
                                    backgroundColor: avatarBackground,
                                    backgroundImage: photoFile == null
                                        ? ImageNetwork
                                            .cachedNetworkImageProvider(
                                            photoUrl,
                                          )
                                        : Image.file(photoFile).image,
                                    radius: 50.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: <Widget>[
                            buildDisplayNameField(),
                            buildBioField()
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: updateProfileData,
                        child: Text(
                          'Update Profile',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(16.0),
                        child: FlatButton.icon(
                          onPressed: () async {
                            signOut(context);
                          },
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
