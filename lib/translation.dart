// 🎯 Dart imports:
import 'dart:ui';

// 📦 Package imports:
import 'package:get/get.dart';

// 🌎 Project imports:
import 'package:flybis/languages/en_us.dart';
import 'package:flybis/languages/pt_br.dart';

class Translation extends Translations {
  // Default locale
  static final locale = Locale('en', 'US');

  // The fallbackLocale saves the day when the locale gets in trouble
  static final fallbackLocale = Locale('en', 'US');

  static final langs = [
    'English',
    'Português',
  ];

  static final locales = [
    Locale('en', 'US'),
    Locale('pt', 'BR'),
  ];

  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': en_US,
        'pt_BR': pt_BR,
      };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = getLocaleFromLanguage(lang);

    Get.updateLocale(locale);
  }

  // Finds language in `langs` list and returns it as Locale
  Locale getLocaleFromLanguage(String lang) {
    for (int i = 0; i < langs.length; i++) {
      if (lang == langs[i]) {
        return locales[i];
      }
    }

    return Get.locale;
  }
}
