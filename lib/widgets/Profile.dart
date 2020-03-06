import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/foundation.dart";

import "package:flybis/pages/App.dart";

import "package:image_picker/image_picker.dart";
import "package:firebase_storage/firebase_storage.dart";

import '../plugins/image_network/image_network.dart';

class Profile {
  Future<String> photoUpload(File file, String userId, String fileId) async {
    if (!kIsWeb) {
      StorageUploadTask uploadTask;

      uploadTask = storageRef.child(userId + "/$fileId.jpg").putFile(file);

      StorageTaskSnapshot storageSnap = await uploadTask.onComplete;

      String downloadUrl = await storageSnap.ref.getDownloadURL();

      usersRef
          .document(userId)
          .updateData({"${fileId.split("-")[0]}Url": downloadUrl});

      return downloadUrl;
    }

    return null;
  }

  Future<File> photoCamera(String userId, String fileId) async {
    File file = await ImagePicker.pickImage(source: ImageSource.camera);
    photoUpload(file, userId, fileId);

    return file;
  }

  Future<File> photoGallery(String userId, String fileId) async {
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    photoUpload(file, userId, fileId);

    return file;
  }
}
