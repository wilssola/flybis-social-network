import "dart:async";
import "dart:io";

import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:flybis/pages/Home.dart';
import "package:flybis/widgets/Header.dart";
import "package:flybis/widgets/Profile.dart";
import 'package:flybis/widgets/Utils.dart';

class CreateAccount extends StatefulWidget {
  final String userId;

  CreateAccount(this.userId);

  @override
  CreateAccountState createState() => CreateAccountState();
}

class CreateAccountState extends State<CreateAccount> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  String username = "";
  String displayName = "";
  String bio = "";

  File photoFile;
  String photoUrl = "";

  photoFromGallery() async {
    var result = await handleChooseFromGallery(context, widget.userId);

    setState(() {
      photoFile = result["photoFile"];
      photoUrl = result["photoUrl"];
    });
  }

  photoFromCamera() async {
    var result = await handleTakePhoto(context, widget.userId);

    setState(() {
      photoFile = result["photoFile"];
      photoUrl = result["photoUrl"];
    });
  }

  submit() {
    if (formKeys[0].currentState.validate() &&
        formKeys[1].currentState.validate() &&
        formKeys[2].currentState.validate()) {
      formKeys[0].currentState.save();
      formKeys[1].currentState.save();
      formKeys[2].currentState.save();

      showSnackbar(scaffoldKey, "Welcome $username!");

      final String divisor = "-";
      String result = username.trim().toLowerCase() +
          divisor +
          displayName.trim() +
          divisor +
          bio.trim() +
          divisor +
          photoUrl +
          divisor +
          "";

      Timer(Duration(seconds: 1), () {
        Navigator.pop(context, result);
      });
    }
  }

  Widget inputLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(
        top: 5,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25.0,
          ),
        ),
      ),
    );
  }

  Widget inputForm(
    GlobalKey formKey,
    Function onSaved,
    String label,
    String hint,
    String shortString,
    String longString,
    int shortInt,
    int longInt, {
    Function validatorCustom,
    String prefixString = "",
    TextCapitalization textCapitalization,
    TextInputType keyboardType,
  }) {
    return Padding(
      padding: EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      child: Container(
        margin: EdgeInsets.only(
          bottom: 5,
        ),
        child: Form(
          key: formKey,
          autovalidate: true,
          child: TextFormField(
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onSaved: onSaved,
            validator: (value) {
              if (value.trim().length < shortInt) {
                return shortString;
              } else if (value.trim().length > longInt) {
                return longString;
              } else {
                if (validatorCustom != null) {
                  validatorCustom(value);
                }
                return "";
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(50))),
              labelText: label,
              labelStyle: TextStyle(
                fontSize: 15.0,
              ),
              hintText: hint,
              prefixText: prefixString,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: scaffoldKey,
      appBar: header(
        context,
        titleText: "Perfil",
        pageColor: Colors.red,
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
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                  ),
                ),
                inputForm(
                    formKeys[0],
                    (value) => username = value,
                    "Usuário",
                    "Usuário",
                    "Minímo de 5 caracteres",
                    "Máximo de 15 caracteres",
                    5,
                    15,
                    prefixString: "@",
                    textCapitalization: TextCapitalization.none,
                    validatorCustom: (String value) {
                  usernamesRef.document(value.trim().toLowerCase()).get(source: Source.serverAndCache).then((doc) {
                    if (doc.exists) {
                      showSnackbar(
                        scaffoldKey,
                        "Usuário já existente",
                        duration: 3600,
                      );
                    } else {
                      hideSnackbar(scaffoldKey);
                    }
                  });
                }),
                inputForm(
                  formKeys[1],
                  (value) => displayName = value,
                  "Nome",
                  "Nome",
                  "Minímo de 10 caracteres",
                  "Máximo de 35 caracteres",
                  10,
                  35,
                  textCapitalization: TextCapitalization.words,
                ),
                inputForm(
                  formKeys[2],
                  (value) => bio = value,
                  "Biografia",
                  "Biografia",
                  "Minímo de 0 caracteres",
                  "Máximo de 100 caracteres",
                  0,
                  100,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: submit,
            child: Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Center(
                child: Text(
                  "Submit",
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
    );
  }
}
