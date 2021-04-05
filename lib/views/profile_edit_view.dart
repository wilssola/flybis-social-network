// 🎯 Dart imports:
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart' as io;

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/global.dart';
import 'package:flybis/models/user_model.dart';
import 'package:flybis/plugins/image_network/image_network.dart';
import 'package:flybis/services/auth_service.dart';
import 'package:flybis/services/profile_service.dart';
import 'package:flybis/services/user_service.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

class ProfileEditView extends StatefulWidget {
  final String owner;
  final Color pageColor;
  final Auth auth = new Auth();

  ProfileEditView(
    this.owner, {
    @required this.pageColor,
  });

  @override
  _ProfileEditViewState createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends State<ProfileEditView> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final ProfileService profileService = ProfileService();

  bool isLoading = false;

  FlybisUser user;

  bool _bioValid = true;
  bool _displayNameValid = true;

  // Photo
  PickedFile photoFile;
  String photoUrl = '';

  // Banner
  PickedFile bannerFile;
  String bannerUrl = '';

  photoFromGallery() async {
    var result = await profileService.photoGallery(
        widget.owner, 'photo-${widget.owner}');

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  photoFromCamera() async {
    var result =
        await profileService.photoCamera(widget.owner, 'photo-${widget.owner}');

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  bannerFromGallery() async {
    var result = await profileService.photoGallery(
        widget.owner, 'banner-${widget.owner}');

    if (mounted) {
      setState(() {
        bannerFile = result;
      });
    }
  }

  bannerFromCamera() async {
    var result = await profileService.photoCamera(
        widget.owner, 'banner-${widget.owner}');

    if (mounted) {
      setState(() {
        bannerFile = result;
      });
    }
  }

  @override
  void initState() {
    getUser();

    super.initState();
  }

  getUser() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    user = await UserService().getUser(widget.owner);

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
            errorText: _displayNameValid ? null : 'Display name too short',
          ),
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
          FlybisUser userOwnerUpdate = flybisUserOwner;
          userOwnerUpdate.displayName = displayNameController.text;
          userOwnerUpdate.bio = bioController.text;

          UserService().updateUser(
            widget.owner,
            userOwnerUpdate,
          );
        }
      });
    }

    Fluttertoast.showToast(msg: 'Profile updated');
  }

  logout() async {
    await widget.auth.signOut(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //extendBodyBehindAppBar: true,
      key: scaffoldKey,
      appBar: AppBar(
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
          ? utils_widget.UtilsWidget()
              .circularProgress(context, color: widget.pageColor)
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
                                    : Image.file(File(bannerFile.path)),
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
                                    backgroundColor: kAvatarBackground,
                                    backgroundImage: photoFile == null
                                        ? ImageNetwork
                                            .cachedNetworkImageProvider(
                                            photoUrl,
                                          )
                                        : Image.file(File(photoFile.path))
                                            .image,
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
                            widget.auth.signOut(context);
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
