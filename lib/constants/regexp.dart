/// Sample Regular expressions to set the argument detectionRegExp
/// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
const String _symbols = '·・ー_';

const String _numbers = '0-9０-９';

const String _englishLetters = 'a-zA-Zａ-ｚＡ-Ｚ';

const String _japaneseLetters = 'ぁ-んァ-ン一-龠';

const String _koreanLetters = '\u1100-\u11FF\uAC00-\uD7A3';

const String _spanishLetters = 'áàãâéêíóôõúüçÁÀÃÂÉÊÍÓÔÕÚÜÇ';

const String _arabicLetters = '\u0621-\u064A';

const String _thaiLetters = '\u0E00-\u0E7F';

const String detectionContentLetters = _symbols +
    _numbers +
    _englishLetters +
    _japaneseLetters +
    _koreanLetters +
    _spanishLetters +
    _arabicLetters +
    _thaiLetters;

/// Regular expression to extract hashtag
/// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
final RegExp hashTagRegExp = RegExp(
  "(?!\\n)(?:^|\\s)(#([$detectionContentLetters]+))",
  multiLine: true,
);

/// Regular expression to extract atsign
/// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
final RegExp atSignRegExp = RegExp(
  "(?!\\n)(?:^|\\s)([@]([$detectionContentLetters]+))",
  multiLine: true,
);

/// Regular expression when you select decorateAtSign
/// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
final RegExp hashTagAtSignRegExp = RegExp(
  "(?!\\n)(?:^|\\s)([#@]([$detectionContentLetters]+))",
  multiLine: true,
);

/// Regular expression when you select decorateAtSign
/// Supports English, Japanese, Korean, Spanish, Arabic, and Thai
final RegExp linkHashTagAtSignRegExp = RegExp(
  "(?!\\n)(?:^|\\s)([#@(http(s))]([(:/.)$detectionContentLetters]+))",
  multiLine: true,
);

/// Email Regex - A predefined type for handling Email matching
const String emailPattern = r"\b[\w\.-]+@[\w\.-]+\.\w{2,4}\b";
final RegExp emailRegExp = RegExp(emailPattern);

/// URL Regex - A predefined type for handling URL matching
const String urlPattern =
    r"[(http(s)?):\/\/(www\.)?a-zA-Z0-9@:._\+~#=]{2,256}\.[a-z]{2,6}\b([-a-zA-Z0-9@:_\+.~#?&//=]*)";
final RegExp urlRegExp = RegExp(urlPattern);
bool urlContains(String string) => string.contains(urlRegExp);
String? urlFromString(String string) => urlRegExp.firstMatch(string)!.group(0);

/// Phone Regex - A predefined type for handling Phone matching
const String phonePattern =
    r"(\+?( |-|\.)?\d{1,2}( |-|\.)?)?(\(?\d{3}\)?|\d{3})( |-|\.)?(\d{3}( |-|\.)?\d{4})";
final RegExp phoneRegExp = RegExp(phonePattern);
