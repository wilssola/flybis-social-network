import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

import 'package:flybis/pages/Home.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadFile(file, userId) async {
  if (!kIsWeb) {
    StorageUploadTask uploadTask;

    uploadTask = storageRef.child(userId + "/$userId.jpg").putFile(file);

    StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    usersRef.document(userId).updateData({'photoUrl': downloadUrl});

    return downloadUrl;
  }

  return null;
}

handleTakePhoto(context, userId) async {
  Navigator.pop(context);

  File file = await ImagePicker.pickImage(source: ImageSource.camera);
  String url = await uploadFile(file, userId);

  return {
    'photoFile': file,
    'photoUrl': url,
  };
}

handleChooseFromGallery(context, userId) async {
  Navigator.pop(context);

  File file = await ImagePicker.pickImage(source: ImageSource.gallery);
  String url = await uploadFile(file, userId);

  return {
    'photoFile': file,
    'photoUrl': url,
  };
}
