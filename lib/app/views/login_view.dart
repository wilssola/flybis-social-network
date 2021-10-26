// 🎯 Dart imports:
import 'dart:math';
import 'dart:ui';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// 📦 Package imports:
import 'package:animated_background/animated_background.dart'
    as animated_background;
import 'package:flybis/core/values/const.dart';
import 'package:flybis/global.dart';
import 'package:get/get.dart';
import 'package:universal_io/io.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/providers/auth_provider.dart';
import 'package:flybis/app/widgets/utils_widget.dart' deferred as utils_widget;

Future<bool> loadLibraries() async {
  await utils_widget.loadLibrary();

  return true;
}

class LoginView extends StatefulWidget {
  final List<Color>? pageColors;

  LoginView({
    this.pageColors,
  });

  @override
  _LoginViewState createState() => _LoginViewState(pageColors: this.pageColors);
}

class _LoginViewState extends State<LoginView> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoad = false, isEmail = false, isObscure = true, isLogin = true;

  String email = '', password = '', message = '';

  late List<Color>? pageColors;
  late Color pageColor;

  _LoginViewState({this.pageColors});

  final AuthProvider _auth = AuthProvider.instance;

  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        this.pageColor =
            widget.pageColors![Random().nextInt(widget.pageColors!.length)];
      });
    }
  }

  void validateAndSubmit() async {
    String email = this.email.trim();
    String password = this.password.trim();

    bool hasLength = email.length > 0 && password.length > 0;

    if (validateAndSave() && hasLength) {
      if (mounted) {
        setState(() {
          this.isLoad = true;
        });
      }

      try {
        if (this.isLogin) {
          await _auth.signIn(email, password);
        } else {
          await _auth.createUser(email, password);
        }
      } catch (error) {
        String message = error.toString();

        if (mounted) {
          setState(() {
            this.message = message.replaceAll(message.split(' ')[0], '');
          });
        }
      }

      Future.delayed(Duration(milliseconds: 500)).then((value) {
        if (mounted) {
          setState(() {
            this.isLoad = false;
          });
        }
      });
    }
  }

  changeLogin() {
    if (mounted) {
      setState(() {
        this.message = '';
        this.isLogin = !this.isLogin;
      });
    }
  }

  // Email
  onChangedEmail(String s) {
    bool isEmail = GetUtils.isEmail(s);

    if (mounted) {
      setState(() {
        this.isEmail = isEmail;
      });
    }

    if (isEmail) {
      onSavedEmail(s);
    }
  }

  validatorEmail(String s) => GetUtils.isEmail(s) ? null : 'Not is email';
  onSavedEmail(String s) => this.email = s;

  // Password
  showPassword() {
    if (mounted) {
      setState(() {
        this.isObscure = !this.isObscure;
      });
    }
  }

  onChangedPassword(String s) {
    if (s.length >= 8) {
      onSavedPassword(s);
    } else {}
  }

  validatorPassword(String s) => s.length >= 8 ? null : 'Bad password';
  onSavedPassword(String s) => this.password = s;

  bool validateAndSave() {
    final form = _formKey.currentState!;

    if (form.validate()) {
      form.save();
      return true;
    }

    return false;
  }

  InputDecoration inputDecoration({
    String? labelText,
    Widget? suffix,
  }) =>
      InputDecoration(
        labelText: labelText,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.0),
          borderSide: BorderSide(),
        ),
        contentPadding: EdgeInsets.all(15),
        suffix: suffix,
      );

  Widget emailForm() {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: inputDecoration(
        labelText: 'Email',
        suffix: Icon(
          Icons.check,
          color: this.isEmail ? Colors.green : Colors.grey,
        ),
      ),
      validator: (v) => this.validatorEmail(v!),
      onChanged: (v) => this.onChangedEmail(v),
      onSaved: (v) => this.onSavedEmail(v!),
      onFieldSubmitted: (v) => this.onSavedEmail(v),
    );
  }

  Widget passwordForm() {
    return TextFormField(
      maxLines: 1,
      obscureText: this.isObscure,
      autofocus: false,
      decoration: inputDecoration(
        labelText: 'Password',
        suffix: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => this.showPassword(),
            child: Icon(
              this.isObscure ? Icons.visibility : Icons.visibility_off,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      validator: (v) => this.validatorPassword(v!),
      onChanged: (v) => this.onChangedPassword(v),
      onSaved: (v) => this.onSavedEmail(v!),
      onFieldSubmitted: (v) => this.onSavedPassword(v),
    );
  }

  Widget errorWidget() {
    final bool hasError = this.message.length > 0;

    return Text(
      hasError ? this.message : '',
      textAlign: TextAlign.center,
      style: TextStyle(
        height: 1.0,
        fontSize: 12.5,
        color: Colors.red,
      ),
    );
  }

  Widget formWidget() {
    return Container(
      width: 350,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            emailForm(),
            SizedBox(height: 15),
            passwordForm(),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }

  Widget primaryButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: MaterialButton(
        height: 50.0,
        minWidth: 200.0,
        color: Colors.blue,
        onPressed: validateAndSubmit,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            this.isLogin ? 'Signin' : 'Signup',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget secondaryButton() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: TextButton(
        onPressed: changeLogin,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Text(
            this.isLogin ? 'Signup a account' : 'Signin a account',
            style: TextStyle(
              fontSize: 15.0,
              color: Theme.of(context).iconTheme.color,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double kWebLoginWidth = 350;

    final double loginHeight = MediaQuery.of(context).size.height;
    final double loginWidth = kNotIsWebOrScreenLittle(context)
        ? MediaQuery.of(context).size.width
        : kWebLoginWidth;
    final Alignment loginAlignment = kNotIsWebOrScreenLittle(context)
        ? Alignment.center
        : Alignment.centerLeft;

    final ImageFilter blurFilter = ImageFilter.blur(sigmaX: 0, sigmaY: 0);
    final Color blurColor =
        Theme.of(context).scaffoldBackgroundColor.withOpacity(0.90);

    final particleOptions = animated_background.ParticleOptions(
      baseColor: pageColor,
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
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return Text('');
        }

        if (isLoad || flybisUserOwner != null) {
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
                  width: loginWidth,
                  height: loginHeight,
                  // Note: Without ClipRect, the blur region will be expanded to full
                  // size of the Image instead of custom size
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: blurFilter,
                      child: Container(color: blurColor),
                    ),
                  ),
                ),
                Align(
                  alignment: loginAlignment,
                  child: Container(
                    alignment: Alignment.center,
                    width: loginWidth,
                    height: loginHeight,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              utils_widget.UtilsWidget().logoText(
                                widget.pageColors!,
                              ),
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
