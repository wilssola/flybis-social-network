// 🎯 Dart imports:
import 'dart:async';
import 'dart:io';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';
import 'package:flybis/core/themes/theme.dart';
import 'package:flybis/app/data/providers/auth_provider.dart';
import 'package:flybis/app/data/services/profile_service.dart';
import 'package:flybis/app/data/services/user_service.dart';
import 'package:flybis/app/widgets/utils_widget.dart' as utils_widget;
import 'package:image_picker/image_picker.dart';

class ProfileCreateView extends StatefulWidget {
  const ProfileCreateView({
    Key? key,
    required this.uid,
  }) : super(key: key);

  final String uid;

  @override
  _ProfileCreateViewState createState() => _ProfileCreateViewState();
}

class _ProfileCreateViewState extends State<ProfileCreateView> {
  final AuthProvider _auth = AuthProvider.instance;

  final ProfileService profileService = ProfileService();

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  List<GlobalKey<FormState>> formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  String? username = '';
  bool usernameValidate = false;

  String? displayName = '';
  String? bio = '';

  File? photoFile;
  String photoUrl = '';

  void setProfileImage(ProfileImageType type, ImageSource source) async {
    if (kIsWeb) {
      utils_widget.UtilsWidget().snackbarWebMissing();
      return;
    }

    XFile? result = await profileService.setProfileImage(
      widget.uid,
      type,
      source,
    );

    if (mounted) {
      setState(() {
        photoFile = File(result!.path);
      });
    }
  }

  void validateUsername(String value) {
    UserService()
        .getUsername(value.trim().toLowerCase().replaceAll(' ', ''))
        .then(
      (String? username) {
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
        formKeys[0].currentState!.validate() &&
        formKeys[1].currentState!.validate() &&
        formKeys[2].currentState!.validate()) {
      formKeys[0].currentState!.save();
      formKeys[1].currentState!.save();
      formKeys[2].currentState!.save();

      Map<String, dynamic> result = {
        'username': username!.trim().replaceAll(' ', ''),
        'usernameLowercase': username!.trim().toLowerCase().replaceAll(' ', ''),
        'usernameUppercase': username!.trim().toUpperCase().replaceAll(' ', ''),
        'displayName': displayName!.trim(),
        'bio': bio!.trim(),
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
                    padding: const EdgeInsets.all(25),
                    child: GestureDetector(
                      onTap: () => setProfileImage(
                        ProfileImageType.photo,
                        ImageSource.gallery,
                      ),
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: CircleAvatar(
                          backgroundImage: photoFile != null
                              ? Image.file(photoFile!).image
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
                child: const Center(
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
