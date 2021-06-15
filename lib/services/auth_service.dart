// Dart

// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:flybis/models/user_model.dart';

class Auth {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final String key = 'user';

  Future<String> signIn(String email, String password) async {
    UserCredential result = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = result.user!.uid;

    return uid;
  }

  Future<String> signUp(String email, String password) async {
    UserCredential result = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await result.user!.sendEmailVerification();

    String uid = result.user!.uid;

    return uid;
  }

  Future<void> recoverPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  User? getUser() {
    User? user = auth.currentUser;

    return user;
  }

  Future<FlybisUser?> getUserOffline() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      FlybisUser user =
          FlybisUser.fromMap(jsonDecode(prefs.getString(key)!), '');

      return user;
    } catch (error) {
      print(error);

      return null;
    }
  }

  Future<void> setUserOffline(FlybisUser? user) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(key, jsonEncode(user));
    } catch (error) {
      print(error);
    }
  }

  Future<void> removeUserOffline() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove(key);
    } catch (error) {
      print(error);
    }
  }

  Future<void> signOut(context) async {
    await auth.signOut();

    await removeUserOffline();

    Phoenix.rebirth(context);
  }
}
