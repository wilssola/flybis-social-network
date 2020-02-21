import 'dart:io';

import "package:flutter/material.dart";

import 'package:flybis/pages/Home.dart';
import 'package:flybis/models/User.dart';
import 'package:flybis/widgets/Profile.dart';
import 'package:flybis/widgets/Progress.dart';

import 'package:flybis/plugins/image_network/image_network.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flybis/services/Auth.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  final Color pageColor;
  EditProfile({
    this.currentUserId,
    this.pageColor,
  });

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  bool isLoading = false;
  User user;
  bool _bioValid = true;
  bool _displayNameValid = true;

  File photoFile;
  String photoUrl = "";
  photoFromGallery() async {
    var result = await handleChooseFromGallery(context, currentUser.id);

    setState(() {
      photoFile = result['photoFile'];
      photoUrl = result['photoUrl'];
    });
  }

  photoFromCamera() async {
    var result = await handleTakePhoto(context, currentUser.id);

    setState(() {
      photoFile = result['photoFile'];
      photoUrl = result['photoUrl'];
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get(source: Source.serverAndCache);
    user = User.fromDocument(doc);
    displayNameController.text = user.displayName;
    bioController.text = user.bio;
    setState(() {
      isLoading = false;
    });
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
              errorText: _bioValid ? null : 'Bio too long'),
        )
      ],
    );
  }

  updateProfileData() {
    setState(() {
      displayNameController.text.trim().length < 3 ||
              displayNameController.text.isEmpty
          ? _displayNameValid = false
          : _displayNameValid = true;

      bioController.text.trim().length > 100
          ? _bioValid = false
          : _bioValid = true;

      if (_displayNameValid && _bioValid) {
        usersRef.document(widget.currentUserId).updateData({
          'displayName': displayNameController.text,
          'bio': bioController.text
        });
      }
    });
    SnackBar snackbar = SnackBar(
      content: Text('Profile updated'),
    );
    _scaffoldKey.currentState.showSnackBar(snackbar);
  }

  logout() async {
    // await googleSignIn.signOut();
    await FirebaseAuth.instance.signOut();

    Phoenix.rebirth(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: widget.pageColor,
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.done,
              size: 30.0,
              color: Colors.green,
            ),
            onPressed: () {
              updateProfileData();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 16.0, bottom: 8),
                        child: GestureDetector(
                          onTap: photoFromGallery,
                          child: Container(
                            width: 150,
                            height: 150,
                            child: CircleAvatar(
                              backgroundImage:
                                  ImageNetwork.cachedNetworkImageProvider(
                                      user.photoUrl != null
                                          ? user.photoUrl
                                          : ""),
                              radius: 50.0,
                            ),
                          ),
                        ),
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
