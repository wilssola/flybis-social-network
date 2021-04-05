// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';
import 'package:universal_io/io.dart' as io;

// 🌎 Project imports:
import 'package:flybis/constants/const.dart';
import 'package:flybis/constants/theme.dart';
import 'package:flybis/services/auth_service.dart';
import 'package:flybis/services/profile_service.dart';
import 'package:flybis/services/user_service.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

class ProfileCreateView extends StatefulWidget {
  final String uid;

  final ProfileService profile = ProfileService();
  final Auth auth = Auth();

  ProfileCreateView({
    @required this.uid,
  });

  @override
  _ProfileCreateViewState createState() => _ProfileCreateViewState();
}

class _ProfileCreateViewState extends State<ProfileCreateView> {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  String username = '';
  bool usernameValidate = false;

  String displayName = '';
  String bio = '';

  File photoFile;
  String photoUrl = '';

  void photoFromGallery() async {
    var result;

    if (!kIsWeb) {
      result =
          await widget.profile.photoGallery(widget.uid, 'banner-${widget.uid}');
    } else {
      utils_widget.UtilsWidget().snackbarWebMissing();
    }

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  void photoFromCamera() async {
    var result;

    if (!kIsWeb) {
      result =
          await widget.profile.photoCamera(widget.uid, 'banner-${widget.uid}');
    } else {
      utils_widget.UtilsWidget().snackbarWebMissing();
    }

    if (mounted) {
      setState(() {
        photoFile = result;
      });
    }
  }

  void validateUsername(String value) {
    UserService()
        .getUsername(value.trim().toLowerCase().replaceAll(' ', ''))
        .then(
      (String username) {
        if (username != null) {
          if (!Get.isSnackbarOpen) {
            Get.snackbar('Flybis', 'Usuário já existente');
          }

          if (mounted) {
            setState(() {
              usernameValidate = true;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              usernameValidate = false;
            });
          }
        }
      },
    );
  }

  void submit() {
    if (!usernameValidate &&
        formKeys[0].currentState.validate() &&
        formKeys[1].currentState.validate() &&
        formKeys[2].currentState.validate()) {
      formKeys[0].currentState.save();
      formKeys[1].currentState.save();
      formKeys[2].currentState.save();

      Map<String, dynamic> result = {
        'username': username.trim().replaceAll(' ', ''),
        'usernameLowercase': username.trim().toLowerCase().replaceAll(' ', ''),
        'usernameUppercase': username.trim().toUpperCase().replaceAll(' ', ''),
        'displayName': displayName.trim(),
        'bio': bio.trim(),
        'photoUrl': photoUrl.trim(),
      };

      return Get.back(result: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return Future.value(false);
      },
      child: Scaffold(
        key: scaffoldKey,
        appBar: utils_widget.UtilsWidget().header(
          context,
          pageColor: pageColors[0],
          removeBackButton: true,
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(25),
                    child: GestureDetector(
                      onTap: photoFromGallery,
                      child: Container(
                        width: 150,
                        height: 150,
                        child: CircleAvatar(
                          backgroundImage: photoFile != null
                              ? Image.file(photoFile).image
                              : null,
                          backgroundColor: kAvatarBackground,
                        ),
                      ),
                    ),
                  ),
                  utils_widget.UtilsWidget().formInput(
                    formKeys[0],
                    (value) => username = value,
                    'Usuário',
                    'Usuário',
                    'Minímo de 5 caracteres',
                    'Máximo de 15 caracteres',
                    5,
                    15,
                    prefixText: '@',
                    textCapitalization: TextCapitalization.none,
                    validator: validateUsername,
                  ),
                  utils_widget.UtilsWidget().formInput(
                    formKeys[1],
                    (value) => displayName = value,
                    'Nome',
                    'Nome',
                    'Minímo de 10 caracteres',
                    'Máximo de 35 caracteres',
                    10,
                    35,
                    textCapitalization: TextCapitalization.words,
                  ),
                  utils_widget.UtilsWidget().formInput(
                    formKeys[2],
                    (value) => bio = value,
                    'Biografia',
                    'Biografia',
                    'Minímo de 0 caracteres',
                    'Máximo de 100 caracteres',
                    0,
                    100,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ],
              ),
            ),
            Container(
              height: 50,
              color: Colors.blue,
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                color: Colors.blue,
                onPressed: submit,
                child: Center(
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
