import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'package:blurhash/blurhash.dart';
import 'package:fluttertoast/fluttertoast.dart';

final Color avatarBackground = Colors.grey[200];
final Color buttonColor = Colors.grey[100];

widthWeb(context) {
  if (MediaQuery.of(context).size.width > 1600) {
    return MediaQuery.of(context).size.width * 0.3;
  } else if (MediaQuery.of(context).size.width > 1440) {
    return MediaQuery.of(context).size.width * 0.35;
  } else if (MediaQuery.of(context).size.width > 1366) {
    return MediaQuery.of(context).size.width * 0.4;
  } else if (MediaQuery.of(context).size.width > 1280) {
    return MediaQuery.of(context).size.width * 0.45;
  } else if (MediaQuery.of(context).size.width > 1024) {
    return MediaQuery.of(context).size.width * 0.5;
  } else {
    return MediaQuery.of(context).size.width;
  }
}

toastDebug(String msg, Color backgroundColor) {
  Fluttertoast.cancel();

  Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}

Future<String> blurHashEncode(path) async {
  Uint8List pixels = await File(path).readAsBytes();
  String blurHash = await BlurHash.encode(pixels, 4, 3);

  return blurHash;
}

Future<File> blurHashDecode(blurHash) async {
  try {
    File imageFile;
    Uint8List imageDataBytes;
    imageDataBytes = await BlurHash.decode(blurHash, 20, 12);
    imageFile = File.fromRawPath(imageDataBytes);

    return imageFile;
  } on PlatformException catch (e) {
    print(e.message);

    return null;
  }
}
