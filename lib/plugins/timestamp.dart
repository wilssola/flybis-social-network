// 📦 Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';

Timestamp timestampNow() {
  return Timestamp.now();
}

FieldValue serverTimestamp() {
  return FieldValue.serverTimestamp();
}
