// Dart

//  Package imports:

// 🐦 Flutter imports:
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';

enum ProfileImageType {
  photo,
  banner,
}

class ProfileService {
  Future<String?> uploadProfileImage(
    XFile file,
    String userId,
    ProfileImageType type,
  ) async {
    if (kIsWeb) return null;

    String fileId = '$type-$userId';
    String path = '$userId/$fileId.jpg';

    Uint8List data = await file.readAsBytes();

    UploadTask uploadTask = storage.child(path).putData(data);

    TaskSnapshot storageSnap = await uploadTask; //.onComplete;

    String downloadUrl = await storageSnap.ref.getDownloadURL();

    /*UserService().updateUser(userId, {
        '${fileId.split('-')[0]}Url': downloadUrl,
      });*/

    return downloadUrl;
  }

  Future<XFile?> setProfileImage(
    String userId,
    ProfileImageType type,
    ImageSource source,
  ) async {
    XFile? file = await ImagePicker().pickImage(source: source);

    await uploadProfileImage(file!, userId, type);

    return file;
  }
}
