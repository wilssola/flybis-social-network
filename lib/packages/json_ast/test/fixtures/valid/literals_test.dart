import 'dart:io';
import 'package:test/test.dart';
import "package:path/path.dart" show dirname, join, normalize;

import '../../types_helper.dart';
import '../../test_helper.dart';
import '../../../lib/error.dart';
import '../../../lib/location.dart';
import '../../../lib/parse.dart';

final location = Location.create;
final ObjectNode Function(List<PropertyNode>, [Location]) object = createObject as dynamic Function(List<dynamic>, [Location]);
final ValueNode Function(String, String, [Location]) id = createIdentifier;
final PropertyNode Function(ValueNode, Node, [Location]) prop = createProperty as dynamic Function(dynamic, dynamic, [Location]);
final ArrayNode Function(List<Node>, [Location]) array = createArray as dynamic Function(List<dynamic>, [Location]);
final LiteralNode Function(dynamic, String, [Location?]) literal = createLiteral;

final ast = new TestAST(
    object([
      prop(
          id('a', '"a"', location(2, 3, 4, 2, 6, 7)),
          literal(null, 'null', location(2, 8, 9, 2, 12, 13)),
          location(2, 3, 4, 2, 12, 13)),
      prop(
          id('b', '"b"', location(3, 3, 17, 3, 6, 20)),
          literal('null', '"null"', location(3, 8, 22, 3, 14, 28)),
          location(3, 3, 17, 3, 14, 28)),
      prop(
          id('c', '"c"', location(4, 3, 32, 4, 6, 35)),
          literal(true, 'true', location(4, 8, 37, 4, 12, 41)),
          location(4, 3, 32, 4, 12, 41)),
      prop(
          id('d', '"d"', location(5, 3, 45, 5, 6, 48)),
          literal('true', '"true"', location(5, 8, 50, 5, 14, 56)),
          location(5, 3, 45, 5, 14, 56)),
      prop(
          id('e', '"e"', location(6, 3, 60, 6, 6, 63)),
          literal(false, 'false', location(6, 8, 65, 6, 13, 70)),
          location(6, 3, 60, 6, 13, 70)),
      prop(
          id('f', '"f"', location(7, 3, 74, 7, 6, 77)),
          literal('false', '"false"', location(7, 8, 79, 7, 15, 86)),
          location(7, 3, 74, 7, 15, 86))
    ], location(1, 1, 0, 8, 2, 88)),
    new Settings());

void main() {
  final currentDirectory = dirname(testScriptPath());
  group("literals", () {
    test("should parse literals correctly", () {
      final jsonFilePath = normalize(join(currentDirectory, 'literals.json'));
      final rawJSON = new File(jsonFilePath).readAsStringSync();
      final parsedAST = parse(rawJSON, Settings());
      assertNode(ast.ast, parsedAST, assertLocation: false, assertIndex: false);
    });
  });
}
