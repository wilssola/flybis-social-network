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

final ast = TestAST(
    object([
      prop(id('a<', '"a<"'), literal(2, '2')),
      prop(
          id('b)', '"b)"'),
          object([
            prop(
                id('c(', '"c("'),
                array([
                  literal('3!', '"3!"'),
                  literal('4:', '"4:"'),
                  literal('5;', '"5;"'),
                  literal('6\'', '"6\'"')
                ])),
            prop(id('d&', '"d&"'),
                object([prop(id('e!', '"e!"'), literal('~_~', '"~_~"'))])),
            prop(id(':e', '":e"'), literal('𠮷', '"𠮷"')),
            prop(id(' f ', '" f "'), literal('*±*∆', '"*±*∆"'))
          ]))
    ]),
    Settings());

void main() {
  final currentDirectory = dirname(testScriptPath());
  group("symbols", () {
    test("should parse symbols correctly", () {
      final jsonFilePath = normalize(join(currentDirectory, 'symbols.json'));
      final rawJSON = new File(jsonFilePath).readAsStringSync();
      final parsedAST = parse(rawJSON, Settings());
      assertNode(ast.ast, parsedAST, assertLocation: false, assertIndex: false);
    });
  });
}
