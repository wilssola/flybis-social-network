// 📦 Package imports:
import 'package:meta/meta.dart';

class FlybisDocument {
  Map<String, dynamic> data;
  String documentId;

  FlybisDocument({
    @required this.data,
    @required this.documentId,
  });

  factory FlybisDocument.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    return FlybisDocument(
      data: data,
      documentId: documentId,
    );
  }
}
