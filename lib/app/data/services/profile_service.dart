// Dart

//  Package imports:

// 🐦 Flutter imports:
import 'package:flutter/foundation.dart';

// 📦 Package imports:
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

// 🌎 Project imports:
import 'package:flybis/core/values/const.dart';

class ProfileService {
  Future<String?> photoUpload(
    PickedFile? file,
    String? userId,
    String fileId,
  ) async {
    if (!kIsWeb) {
      UploadTask uploadTask;

      uploadTask = storage
          .child('$userId/$fileId.jpg')
          .putData(await file!.readAsBytes());

      TaskSnapshot storageSnap = await uploadTask; //.onComplete;

      String downloadUrl = await storageSnap.ref.getDownloadURL();

      /*UserService().updateUser(userId, {
        '${fileId.split('-')[0]}Url': downloadUrl,
      });*/

      return downloadUrl;
    }

    return null;
  }

  Future<PickedFile?> photoCamera(String? userId, String fileId) async {
    PickedFile? file = await ImagePicker().getImage(source: ImageSource.camera);

    await photoUpload(file, userId, fileId);

    return file;
  }

  Future<PickedFile?> photoGallery(String? userId, String fileId) async {
    PickedFile? file =
        await ImagePicker().getImage(source: ImageSource.gallery);

    await photoUpload(file, userId, fileId);

    return file;
  }
}
