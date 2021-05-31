// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/services/auth_service.dart';
import 'package:flybis/widgets/utils_widget.dart' as utils_widget;

import 'package:animated_background/animated_background.dart'
    deferred as animated_background;

Future<bool> loadLibraries() async {
  await animated_background.loadLibrary();

  return true;
}

enum FormType { SIGNIN, SIGNUP }

class LoginView extends StatefulWidget {
  final List<Color> pageColors;

  final Auth auth = new Auth();

  LoginView({
    this.pageColors,
  });

  @override
  _LoginViewState createState() => _LoginViewState(pageColors: this.pageColors);
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FormType formType = FormType.SIGNIN;
  String formEmail;
  String formPassword;

  bool isLoad = false;
  String errorMessage = '';

  final List<Color> pageColors;
  Color pageColor = Colors.blue;

  _LoginViewState({this.pageColors});

  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        //this.pageColor = pageColors[Random().nextInt(pageColors.length)];
      });
    }
  }

  showSignupForm() {
    formKey.currentState.reset();
    errorMessage = '';

    if (mounted) {
      setState(() {
        formType = FormType.SIGNUP;
      });
    }
  }

  showLoginForm() {
    formKey.currentState.reset();
    errorMessage = '';

    if (mounted) {
      setState(() {
        formType = FormType.SIGNIN;
      });
    }
  }

  validateAndSubmit() async {
    if (mounted) {
      setState(() {
        errorMessage = '';
        isLoad = true;
      });
    }
    if (validateAndSave()) {
      try {
        if (formType == FormType.SIGNIN) {
          await widget.auth.signIn(formEmail, formPassword);
        } else {
          await widget.auth.signUp(formEmail, formPassword);
        }

        if (mounted) {
          setState(() {
            //isLoad = false;
          });
        }
      } catch (error) {
        if (mounted) {
          setState(() {
            isLoad = false;
            if (!kIsWeb) {
              if (Platform.isIOS) {
                errorMessage = error.details;
              } else {
                errorMessage = error.message;
              }
            }
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          isLoad = false;
        });
      }
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;

    if (form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  Widget errorWidget() {
    if (errorMessage.length > 0 && errorMessage != null) {
      return new Text(
        errorMessage,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
        ),
      );
    }

    return Padding(padding: EdgeInsets.zero);
  }

  Widget formWidget() {
    return Container(
      width: 350,
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            formEmailWidget(),
            formPasswordWidget(),
          ],
        ),
      ),
    );
  }

  Widget formEmailWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Email',
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(),
          ),
        ),
        validator: (value) => value.isEmpty ? 'Email cannot be empty' : null,
        onChanged: (value) => formEmail = value.trim(),
      ),
    );
  }

  Widget formPasswordWidget() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: InputDecoration(
          labelText: 'Password',
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25.0),
            borderSide: BorderSide(),
          ),
        ),
        validator: (value) => value.isEmpty ? 'Password cannot be empty' : null,
        onChanged: (value) => formPassword = value.trim(),
        onFieldSubmitted: (String string) {
          validateAndSubmit();
        },
      ),
    );
  }

  Widget primaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: MaterialButton(
        minWidth: 200.0,
        height: 40.0,
        color: Colors.blue,
        child: formType == FormType.SIGNIN
            ? Text(
                'Signin',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              )
            : Text(
                'Signup',
                style: TextStyle(fontSize: 20.0, color: Colors.white),
              ),
        onPressed: validateAndSubmit,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
      ),
    );
  }

  Widget secondaryButton() {
    return FlatButton(
      child: formType == FormType.SIGNIN
          ? Text(
              'Signup a account',
              style: TextStyle(
                fontSize: 18.0,
              ),
            )
          : Text(
              'Signin a account',
              style: TextStyle(
                fontSize: 18.0,
              ),
            ),
      onPressed: formType == FormType.SIGNIN ? showSignupForm : showLoginForm,
    );
  }

  @override
  Widget build(BuildContext context) {
    const double kWebLoginWidth = 350;

    final Color backgroundColor =
        widget.pageColors[Random().nextInt(widget.pageColors.length)];

    final particleOptions = animated_background.ParticleOptions(
      baseColor: widget.pageColors[Random().nextInt(widget.pageColors.length)],
      spawnOpacity: 0,
      opacityChangeRate: 0.25,
      minOpacity: 0.15,
      maxOpacity: 0.75,
      spawnMinSpeed: 35,
      spawnMaxSpeed: 75,
      spawnMinRadius: 7.5,
      spawnMaxRadius: 15,
      particleCount: 50,
    );

    return FutureBuilder(
      future: loadLibraries(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        if (isLoad) {
          return utils_widget.UtilsWidget().centerCircularProgress(context);
        }

        return Scaffold(
          body: animated_background.AnimatedBackground(
            vsync: this,
            behaviour: animated_background.RandomParticleBehaviour(
              options: particleOptions,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  width: !kIsWeb
                      ? MediaQuery.of(context).size.width
                      : kWebLoginWidth,
                  height: MediaQuery.of(context).size.height,
                  // Note: without ClipRect, the blur region will be expanded to full
                  // size of the Image instead of custom size
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      child: Container(
                        color: Theme.of(context)
                            .scaffoldBackgroundColor
                            .withOpacity(0.65),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: !kIsWeb ? Alignment.center : Alignment.centerLeft,
                  child: Container(
                    //color: Theme.of(context).scaffoldBackgroundColor,
                    alignment: Alignment.center,
                    width: !kIsWeb
                        ? MediaQuery.of(context).size.width
                        : kWebLoginWidth,
                    height: MediaQuery.of(context).size.height,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              utils_widget.UtilsWidget()
                                  .logoText(widget.pageColors),
                              formWidget(),
                              primaryButton(),
                              secondaryButton(),
                              errorWidget(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
