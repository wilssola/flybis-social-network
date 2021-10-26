import 'dart:io';
import 'constants.dart';

/// Class for erase method
class ANSIErase {
  factory ANSIErase() => _instance;

  // ignore: unused_element
  ANSIErase._();

  /// ANSIErase single instance
  static final ANSIErase _instance = ANSIErase();

  /// Clear the screen and home cursor
  void clearScreen() {
    if (stdout.supportsAnsiEscapes) {
      stdout.write('${kESC}2J');
    }
  }

  /// Clear line until end
  /// - [beginOfLine] : whether clear whole line
  void clearLine({bool? beginOfLine = true}) {
    assert(beginOfLine != null);
    if (stdout.supportsAnsiEscapes) {
      stdout.write('${beginOfLine! ? '\r' : ''}${kESC}K');
    }
  }
}
