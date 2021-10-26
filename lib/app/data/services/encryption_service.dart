// 🎯 Dart imports:
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// 📦 Package imports:
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:tuple/tuple.dart';

// 🌎 Project imports:
import 'package:flybis/global.dart';
import 'package:flybis/plugins/crc.dart';

class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  static const String CRC_SEPARATOR = '&';

  String encryptAESCryptoJS(String plainText, String passphrase) {
    try {
      final Uint8List salt = genRandomWithNonZero(8);
      final Tuple2<Uint8List, Uint8List> keyndIV =
          deriveKeyAndIV(passphrase, salt);

      final Key key = Key(keyndIV.item1);
      final IV iv = IV(keyndIV.item2);

      final Encrypter encrypter =
          Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      final Encrypted encrypted = encrypter.encrypt(plainText, iv: iv);

      final Uint8List encryptedBytesWithSalt = Uint8List.fromList(
          createUint8ListFromString('Salted__') + salt + encrypted.bytes);

      return base64.encode(encryptedBytesWithSalt);
    } catch (error) {
      logger.e(error);

      throw error;
    }
  }

  String decryptAESCryptoJS(String encrypted, String passphrase) {
    try {
      final Uint8List encryptedBytesWithSalt = base64.decode(encrypted);
      final Uint8List encryptedBytes =
          encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
      final Uint8List salt = encryptedBytesWithSalt.sublist(8, 16);

      final Tuple2<Uint8List, Uint8List> keyndIV =
          deriveKeyAndIV(passphrase, salt);

      final Key key = Key(keyndIV.item1);
      final IV iv = IV(keyndIV.item2);

      final Encrypter encrypter =
          Encrypter(AES(key, mode: AESMode.cbc, padding: 'PKCS7'));
      final String decrypted =
          encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);

      return decrypted;
    } catch (error) {
      logger.e(error);

      return encrypted;
    }
  }

  Tuple2<Uint8List, Uint8List> deriveKeyAndIV(
    String passphrase,
    Uint8List salt,
  ) {
    final Uint8List password = createUint8ListFromString(passphrase);
    Uint8List concatenatedHashes = Uint8List(0);
    Uint8List currentHash = Uint8List(0);
    bool enoughBytesForKey = false;
    Uint8List preHash = Uint8List(0);

    while (!enoughBytesForKey) {
      int preHashLength = currentHash.length + password.length + salt.length;
      if (currentHash.length > 0)
        preHash = Uint8List.fromList(currentHash + password + salt);
      else
        preHash = Uint8List.fromList(password + salt);

      currentHash = md5.convert(preHash).bytes as Uint8List;
      concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
      if (concatenatedHashes.length >= 48) enoughBytesForKey = true;
    }

    final Uint8List keyBtyes = concatenatedHashes.sublist(0, 32);
    final Uint8List ivBtyes = concatenatedHashes.sublist(32, 48);

    return new Tuple2(keyBtyes, ivBtyes);
  }

  Uint8List createUint8ListFromString(String s) {
    var ret = new Uint8List(s.length);

    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }

    return ret;
  }

  Uint8List genRandomWithNonZero(int seedLength) {
    final Random random = Random.secure();
    const int randomMax = 245;

    final Uint8List uint8list = Uint8List(seedLength);

    for (int i = 0; i < seedLength; i++) {
      uint8list[i] = random.nextInt(randomMax) + 1;
    }

    return uint8list;
  }

  String encryptWithCRC(String string, String key) {
    try {
      String encryptedString = encryptAESCryptoJS(string, key);
      int crc = CRC32.compute(string);

      return '$encryptedString$CRC_SEPARATOR$crc';
    } catch (error) {
      logger.e(error);

      throw error;
    }
  }

  String decryptWithCRC(String string, String key) {
    try {
      if (string.contains(CRC_SEPARATOR)) {
        List<String> split = string.split(CRC_SEPARATOR);

        String decryptedString = decryptAESCryptoJS(split[0], key);
        String crcString = split[1];

        int? crc = int.tryParse(crcString);

        if (crc != null) {
          if (CRC32.compute(decryptedString) == crc) {
            return decryptedString;
          }
        }
      }
    } catch (error) {
      logger.e(error);

      return string;
    }

    return decryptAESCryptoJS(string, key);
  }
}
