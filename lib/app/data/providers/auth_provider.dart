// 🎯 Dart imports:
import 'dart:async';
import 'dart:convert';

// 📦 Package imports:
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/models/user_model.dart';

class AuthProvider {
  AuthProvider._();
  static final AuthProvider instance = AuthProvider._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String flybisUserOfflineKey = 'flybisUser';

  Future<String> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = result.user!.uid;

      return uid;
    } on FirebaseAuthException catch (error) {
      throw error;
    }
  }

  Future<String> createUser(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user!.sendEmailVerification();

      String uid = result.user!.uid;

      return uid;
    } on FirebaseAuthException catch (error) {
      throw error;
    }
  }

  Future<void> passwordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? getUser() {
    User? user = _auth.currentUser;

    return user;
  }

  Future<FlybisUser?> getUserOffline() async {
    FlybisUser? flybisUser;

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      String? flybisUserJson = prefs.getString(flybisUserOfflineKey);

      flybisUser = FlybisUser.fromMap(
        jsonDecode(flybisUserJson!),
        flybisUserOfflineKey,
      );
    } catch (error) {
      print(error);
    }

    return flybisUser;
  }

  Future<void> setUserOffline(FlybisUser flybisUser) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.setString(flybisUserOfflineKey, jsonEncode(flybisUser));
    } catch (error) {
      print(error);
    }
  }

  Future<void> removeUserOffline() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      prefs.remove(flybisUserOfflineKey);
    } catch (error) {
      print(error);
    }
  }

  Future<void> signOut(context) async {
    await _auth.signOut();

    await removeUserOffline();

    Phoenix.rebirth(context);
  }
}
