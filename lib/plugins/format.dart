// 🎯 Dart imports:
import 'dart:math';

// 📦 Package imports:
import 'package:intl/intl.dart';

logBase(num x, num base) => log(x) / log(base);
log10(num x) => log(x) / ln10;

String formatCompactNumber(value) {
  var f = NumberFormat.compact(locale: 'en_US');
  return f.format(value).toString();
}

String messageTimestampFormat(dynamic timestamp) {
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

String messageContentFormat(
  String type,
  String content,
) {
  String message;

  // MessageType: 0 = Text, 1 = Image, 2 = Sticker
  switch (type) {
    case 'text':
      {
        message = content;
      }
      break;
    case 'image':
      {
        message = 'Imagem';
      }
      break;
    case 'video':
      {
        message = 'Vídeo';
      }
      break;
    case 'giphy':
      {
        message = 'Giphy';
      }
      break;
    default:
      {
        message = '';
      }
  }

  return message;
}

String enumToString(dynamic object) {
  return object.toString().toUpperCase().split('.')[1];
}
