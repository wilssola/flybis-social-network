import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:particles_flutter/particles_flutter.dart';

import '../services/Auth.dart';
import '../widgets/Utils.dart';
import '../widgets/Progress.dart';

class Login extends StatefulWidget {
  final List<Color> pageColors;

  Login({
    this.pageColors,
  });

  @override
  LoginState createState() => LoginState();
}

enum FormMode { SIGNIN, SIGNUP }

class LoginState extends State<Login> {
  String formEmail;
  String formPassword;
  FormMode formMode = FormMode.SIGNIN;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isLoad = false;
  String errorMessage = '';

  showSignupForm() {
    formKey.currentState.reset();
    errorMessage = '';

    if (mounted) {
      setState(() {
        formMode = FormMode.SIGNUP;
      });
    }
  }

  showLoginForm() {
    formKey.currentState.reset();
    errorMessage = '';

    if (mounted) {
      setState(() {
        formMode = FormMode.SIGNIN;
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
        if (formMode == FormMode.SIGNIN) {
          await signIn(formEmail, formPassword);
        } else {
          await signUp(formEmail, formPassword);
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
        style: TextStyle(
          fontSize: 13.0,
          color: Colors.red,
          height: 1.0,
        ),
      );
    } else {
      return Padding(padding: EdgeInsets.zero);
    }
  }

  Widget progressWidget() {
    if (isLoad) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Padding(padding: EdgeInsets.zero);
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
      ),
    );
  }

  Widget primaryButton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 15.0, 0.0, 0.0),
      child: MaterialButton(
        elevation: 0,
        minWidth: 200.0,
        height: 42.0,
        color: Colors.blue,
        child: formMode == FormMode.SIGNIN
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
      child: formMode == FormMode.SIGNIN
          ? Text('Signup a account', style: TextStyle(fontSize: 18.0))
          : Text('Signin a account', style: TextStyle(fontSize: 18.0)),
      onPressed: formMode == FormMode.SIGNIN ? showSignupForm : showLoginForm,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoad) {
      return circularProgress();
    }

    return Scaffold(
      body: Stack(
        children: <Widget>[
          CircularParticle(
            key: UniqueKey(),
            awayRadius: 75,
            numberOfParticles: 150,
            speedOfParticles: 1,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            onTapAnimation: true,
            particleColor: Colors.white.withAlpha(150),
            awayAnimationDuration: Duration(milliseconds: 500),
            maxParticleSize: 8,
            isRandSize: true,
            isRandomColor: true,
            randColorList: widget.pageColors,
            awayAnimationCurve: Curves.easeInOutBack,
            enableHover: true,
            hoverColor:
                widget.pageColors[Random().nextInt(widget.pageColors.length)],
            hoverRadius: 75,
            connectDots: false, //not recommended
          ),
          Align(
            alignment: !kIsWeb ? Alignment.center : Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              alignment: Alignment.center,
              width: 350,
              height: !kIsWeb ? 450 : MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  logoText(widget.pageColors),
                  Container(width: 350, child: formWidget()),
                  primaryButton(),
                  secondaryButton(),
                  errorWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
