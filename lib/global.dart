// 📦 Package imports:
import 'package:logger/logger.dart';

// 🌎 Project imports:
import 'package:flybis/app/data/models/user_model.dart';

// Logger
final Logger logger = Logger(
  printer: PrettyPrinter(
    printTime: true,
  ),
);

// Agora.io
late String agoraIoToken;

// Flybis
FlybisUser? flybisUserOwner;
