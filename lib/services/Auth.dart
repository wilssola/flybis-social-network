import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

final FirebaseAuth auth = FirebaseAuth.instance;

Future<String> signIn(String email, String password) async {
  AuthResult result = await auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );

  String uid = result.user.uid;

  return uid;
}

Future<String> signUp(String email, String password) async {
  AuthResult result = await auth.createUserWithEmailAndPassword(
    email: email,
    password: password,
  );

  await result.user.sendEmailVerification();

  String uid = result.user.uid;

  return uid;
}

Future<FirebaseUser> getCurrentUser() async {
  FirebaseUser user = await auth.currentUser();
  return user;
}

Future<void> signOut(context) async {
  await auth.signOut();

  Phoenix.rebirth(context);
}
