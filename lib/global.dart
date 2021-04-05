// 📦 Package imports:
import 'package:logger/logger.dart';

// 🌎 Project imports:
import 'package:flybis/models/user_model.dart';

Logger logger = Logger(
  printer: PrettyPrinter(
    printTime: true,
  ),
);

FlybisUser flybisUserOwner;

// Agora
String agoraIoToken;
