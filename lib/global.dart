// 📦 Package imports:
import 'package:logger/logger.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/models/user_model.dart';

// Logger
final Logger logger = Logger(
  printer: PrettyPrinter(
    methodCount: 8,
    errorMethodCount: 8,
    colors: true,
    printEmojis: true,
    printTime: true,
    noBoxingByDefault: true,
  ),
);

String? flybisAgoraToken = '';
