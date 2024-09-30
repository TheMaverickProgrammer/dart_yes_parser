import 'package:test/test.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/yes_parser.dart';

ParseCompleteFunc checkDelimeterClosure(
    {required String testName,
    required List<String> values,
    List<String>? expectedErrors}) {
  return (List<ElementInfo> elements, List<ErrorInfo> errors) {
    //print(elements.map((e) => e.element));

    assert(values.length == elements.length,
        '[$testName] Expected elements and test values to be equal.\nWas: ${elements.length}.\nExpected: ${values.length})');

    if (expectedErrors != null) {
      assert(expectedErrors.length == errors.length,
          '[$testName] Expected to have the same number of errors as values.\nWas: ${errors.length}.\nExpected: ${expectedErrors.length}');
    }
    final int len = values.length;
    for (int i = 0; i < len; i++) {
      final Element el = elements[i].element;
      expect(el.toString(), values[i],
          reason:
              '[$testName] Parsed element values[$i] did not match test string');
    }
  };
}

ParseCompleteFunc checkArgsClosure(
    {required String testName,
    required List<List<KeyVal?>> values,
    List<String>? expectedErrors,
    dynamic matcher}) {
  return (List<ElementInfo> elements, List<ErrorInfo> errors) {
    //print(elements.map((e) => e.element));

    assert(values.length == elements.length,
        '[$testName] Expected elements and test values to be equal.\nWas: ${elements.length}.\nExpected: ${values.length})');

    if (expectedErrors != null) {
      assert(expectedErrors.length == errors.length,
          '[$testName] Expected to have the same number of errors as values.\nWas: ${errors.length}.\nExpected: ${expectedErrors.length}');
    }
    final int len = values.length;
    for (int i = 0; i < len; i++) {
      final Element el = elements[i].element;
      final List<KeyVal?> args = values[i];

      final int argLen = args.length;
      expect(el.args.length, argLen,
          reason: '[$testName] Parsed args length is incorrect for i=$i');

      for (int j = 0; j < argLen; j++) {
        expect(el.args[j], matcher?.call(args[j]) ?? args[j],
            reason:
                '[$testName] Parsed KeyVal elements[$i] had unexpected args[$j] value');
      }
    }
  };
}

void main() {
  test("Element toString() correctness test", () async {
    const doc = <String>[
      'a key = val',
      'b val val2',
      'c val',
      'd key=val',
      'e key = val,',
      'f key = val,',
      'g key = val aaa bbb',
      'h key = val ,',
      'i key = val,key2=val2',
      'j key = val , key2 = val2',
      'k key= val ,val2 aaa',
      'l key =val ,    key2   =val2,',
      'm val',
      'n key=',
      'o key =',
      'p key = ',
      'q',
      'r key =val ,    key2   =val2, key3 = val3',
      's val val2 val3',
      't key=val key2=val2 key3=val3',
      'u "aaa bbb"',
      '"v" abcd',
      'w x y z="123"',
    ];

    const expected = <String>[
      'a key=val',
      'b val, val2',
      'c val',
      'd key=val',
      'e key=val',
      'f key=val',
      'g key="val aaa bbb"',
      'h key=val',
      'i key=val, key2=val2',
      'j key=val, key2=val2',
      'k key=val, "val2 aaa"',
      'l key=val, key2=val2',
      'm val',
      'n key=',
      'o key=',
      'p key=',
      'q',
      'r key=val, key2=val2, key3=val3',
      's val, val2, val3',
      't key=val, key2=val2, key3=val3',
      'u "aaa bbb"',
      'v abcd',
      'w x, y, z=123',
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete:
          checkDelimeterClosure(testName: 'Delimiter Test', values: expected),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });

  test("KeyVal quoted keys and values are parsed without quotes", () async {
    const doc = <String>[
      'a "aaa bbb"',
      'b "crab battle" "efficient car goose" "key3"="value3" "key4"=value4 "value5"',
      'c "1234"',
    ];

    final expectedNotQuoted = <List<KeyVal>>[
      [KeyVal(val: 'aaa bbb')],
      [
        KeyVal(val: 'crab battle'),
        KeyVal(val: 'efficient car goose'),
        KeyVal(key: 'key3', val: 'value3'),
        KeyVal(key: 'key4', val: 'value4'),
        KeyVal(val: 'value5'),
      ],
      [KeyVal(val: '1234')],
    ];

    final docStr = doc.join('\n');
    final p = YesParser.fromString(
      docStr,
      onComplete:
          checkArgsClosure(testName: 'Quoted Test', values: expectedNotQuoted),
    );
    await p.join();
  });

  test("KeyVals parse correctly", () async {
    const doc = <String>[
      'a key = val',
      'b val val2',
      'c val',
      'd key=val',
      'e key = val,',
      'f key = val,',
      'g key = val aaa bbb',
      'h key = val ,',
      'i key = val,key2=val2',
      'j key = val , key2 = val2',
      'k key= val ,val2 aaa',
      'l key =val ,    key2   =val2,',
      'm val',
      'n key=',
      'o key =',
      'p key = ',
      'q',
      'r key =val ,    key2   =val2, key3 = val3',
      's val val2 val3',
      't key=val key2=val2 key3=val3',
      'u "aaa bbb"',
      'v "crab battle" "efficient car goose" "key3"="value3" "key4"=value4 value5 "value6"',
      'w x y z="123"',
    ];

    final expected = <List<KeyVal>>[
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(val: 'val'), KeyVal(val: 'val2')],
      [KeyVal(val: 'val')],
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(key: 'key', val: 'val aaa bbb')],
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(key: 'key', val: 'val'), KeyVal(key: 'key2', val: 'val2')],
      [KeyVal(key: 'key', val: 'val'), KeyVal(key: 'key2', val: 'val2')],
      [KeyVal(key: 'key', val: 'val'), KeyVal(val: 'val2 aaa')],
      [KeyVal(key: 'key', val: 'val'), KeyVal(key: 'key2', val: 'val2')],
      [KeyVal(val: 'val')],
      [KeyVal(key: 'key', val: '')],
      [KeyVal(key: 'key', val: '')],
      [KeyVal(key: 'key', val: '')],
      [],
      [
        KeyVal(key: 'key', val: 'val'),
        KeyVal(key: 'key2', val: 'val2'),
        KeyVal(key: 'key3', val: 'val3'),
      ],
      [
        KeyVal(val: 'val'),
        KeyVal(val: 'val2'),
        KeyVal(val: 'val3'),
      ],
      [
        KeyVal(key: 'key', val: 'val'),
        KeyVal(key: 'key2', val: 'val2'),
        KeyVal(key: 'key3', val: 'val3'),
      ],
      [KeyVal(val: 'aaa bbb')],
      [
        KeyVal(val: 'crab battle'),
        KeyVal(val: 'efficient car goose'),
        KeyVal(key: 'key3', val: 'value3'),
        KeyVal(key: 'key4', val: 'value4'),
        KeyVal(val: 'value5'),
        KeyVal(val: 'value6'),
      ],
      [
        KeyVal(val: 'x'),
        KeyVal(val: 'y'),
        KeyVal(key: 'z', val: '123'),
      ],
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkArgsClosure(testName: 'Parse Test', values: expected),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });

  test("Parse KeyVal fail test (sanity check)", () async {
    const doc = <String>[
      'a key = val',
      'b val val2',
      'c val',
      'd key=val',
      'e key = val,',
      'f key = val aaa bbb',
      'g key = val ,',
      'i key = val , val2    ,',
      'j val val2 val3',
      'w x y z="123"',
    ];

    final isNotExpected = <List<KeyVal?>>[
      [KeyVal(key: 'key', val: '')],
      [KeyVal(val: 'val val2'), null],
      [KeyVal(val: 'val ')],
      [KeyVal(key: 'key', val: ' val')],
      [KeyVal(val: 'val')],
      [KeyVal(key: 'key', val: 'val aaa')],
      [KeyVal(key: 'key', val: 'val ')],
      [KeyVal(key: 'k', val: 'v'), KeyVal(val: 'val2    ')],
      [KeyVal(val: 'val val2 val3'), null, null],
      [
        KeyVal(key: 'x y z', val: '123'),
        null,
        null,
      ],
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkArgsClosure(
          testName: 'Sanity Check', values: isNotExpected, matcher: isNot),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });
}
