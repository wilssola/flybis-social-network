import 'dart:io';
import 'package:test/test.dart';
import "package:path/path.dart" show dirname, join, normalize;

import '../../types_helper.dart';
import '../../test_helper.dart';
import '../../../lib/error.dart';
import '../../../lib/parse.dart';

final ArrayNode Function(List<Node>, [Location]) array = createArray as dynamic Function(List<dynamic>, [dynamic]);
final LiteralNode Function(dynamic, String, [Location]) literal = createLiteral as dynamic Function(dynamic, String, [dynamic]);

final ast = new TestAST(
    array([
      literal(1, '1'),
      literal(1.2, '1.2'),
      literal(1.2e3, '1.2e3'),
      literal(1.2e-3, '1.2e-3')
    ]),
    new Settings());

void main() {
  final currentDirectory = dirname(testScriptPath());
  group("exponential numbers", () {
    test("should parse an exponentian number correctly", () {
      final jsonFilePath =
          normalize(join(currentDirectory, 'exponential_numbers.json'));
      final rawJSON = new File(jsonFilePath).readAsStringSync();
      final parsedAST = parse(rawJSON, Settings());
      assertNode(ast.ast, parsedAST, assertLocation: false, assertIndex: false);
    });
  });
}
