// 📦 Package imports:

class FlybisDocument {
  Map<String, dynamic>? data;
  String? documentId;

  FlybisDocument({
    required this.data,
    required this.documentId,
  });

  factory FlybisDocument.fromMap(
    Map<String, dynamic>? data,
    String? documentId,
  ) {
    if (data == null) {
      return FlybisDocument(data: null, documentId: null);
    }

    return FlybisDocument(
      data: data,
      documentId: documentId,
    );
  }
}