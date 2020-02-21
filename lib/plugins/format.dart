import 'package:cloud_firestore/cloud_firestore.dart';
import "package:intl/intl.dart";
import "dart:math";

logBase(num x, num base) => log(x) / log(base);
log10(num x) => log(x) / ln10;

String formatCompactNumber(value) {
  var f = NumberFormat.compact(locale: "en_US");
  return f.format(value).toString();
}

String lastMessageTimestampFormat(Timestamp timestamp) {
  final dayInMilliseconds = 24 * 60 * 60 * 1000;
  final DateTime date = timestamp.toDate();
  final int difference =
      date.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;

  if (difference < dayInMilliseconds) {
    return DateFormat('kk:mm').format(date);
  } else {
    return DateFormat('d.M.y').format(date);
  }
}

String lastMessageContentFormat(
  int lastMessageType,
  String lastMessageContent,
) {
  String lastMessage;

  // MessageType: 0 = Text, 1 = Image, 2 = Sticker
  switch (lastMessageType) {
    case 0:
      {
        lastMessage = lastMessageContent;
      }
      break;
    case 1:
      {
        lastMessage = "Imagem";
      }
      break;
    case 2:
      {
        lastMessage = "Sticker";
      }
      break;
    default:
      {
        lastMessage = "";
      }
  }

  return lastMessage;
}
