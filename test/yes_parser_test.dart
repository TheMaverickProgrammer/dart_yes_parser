import 'package:test/test.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/yes_parser.dart';

ParseCompleteFunc checkDelimeterClosure(
    {required String testName,
    required List<String> values,
    List<String>? expectedErrors}) {
  return (List<ElementInfo> elements, List<ErrorInfo> errors) {
    expect(
      values.length,
      elements.length,
      reason: '[$testName] Expected elements and test values to be equal.'
          '\nWas: ${elements.length}. Expected: ${values.length})',
    );

    if (expectedErrors != null) {
      expect(
        expectedErrors.length,
        errors.length,
        reason:
            '[$testName] Expected to have the same number of errors as values.'
            '\nWas: ${errors.length}. Expected: ${expectedErrors.length}',
      );
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
    expect(
      values.length,
      elements.length,
      reason: '[$testName] Expected elements and test values to be equal.'
          '\nWas: ${elements.length}. Expected: ${values.length})',
    );

    if (expectedErrors != null) {
      expect(
        expectedErrors.length,
        errors.length,
        reason:
            '[$testName] Expected to have the same number of errors as values.'
            '\nWas: ${errors.length}. Expected: ${expectedErrors.length}',
      );
    }

    final int len = values.length;
    for (int i = 0; i < len; i++) {
      final Element el = elements[i].element;
      final List<KeyVal?> args = values[i];

      final int argLen = args.length;

      // These two DO NOT match in length. Pass early so not to
      // throw an exception when testing for failures.
      if (matcher == isNot && el.args.length != argLen) continue;

      expect(
        el.args.length,
        argLen,
        reason:
            '[$testName] Parsed args length is incorrect for element=${el.text}',
      );

      if (matcher == isNot) {
        // Make sure at least one arg does not match
        bool oneFailed = false;
        for (int j = 0; j < argLen; j++) {
          if (el.args[j] == args[j]) continue;
          oneFailed = true;
          break;
        }
        expect(
          oneFailed,
          true,
          reason:
              '[$testName] Was not expecting all args to be the same for element ${el.text}',
        );
      } else {
        // Make sure every arg matches!
        for (int j = 0; j < argLen; j++) {
          expect(
            el.args[j],
            matcher?.call(args[j]) ?? args[j],
            reason:
                '[$testName] Parsed KeyVal for element ${el.text} had unexpected args[$j] value',
          );
        }
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
      'f key= val aaa bbb',
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
      'x a=b -c',
    ];

    const expected = <String>[
      'a key=val',
      'b val, val2',
      'c val',
      'd key=val',
      'e key=val',
      'f key=, val, aaa, bbb',
      'g key, val, aaa, bbb',
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
      'x a=b, -c',
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
      'f key= val aaa bbb',
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
      'x a=b -c',
    ];

    final expected = <List<KeyVal>>[
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(val: 'val'), KeyVal(val: 'val2')],
      [KeyVal(val: 'val')],
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(key: 'key', val: 'val')],
      [
        KeyVal(key: 'key', val: ''),
        KeyVal(val: 'val'),
        KeyVal(val: 'aaa'),
        KeyVal(val: 'bbb')
      ],
      [
        KeyVal(val: 'key'),
        KeyVal(val: 'val'),
        KeyVal(val: 'aaa'),
        KeyVal(val: 'bbb')
      ],
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
      [KeyVal(key: 'a', val: 'b'), KeyVal(val: '-c')],
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
      [KeyVal(val: 'val val2')],
      [KeyVal(val: 'val ')],
      [KeyVal(key: 'key', val: ' val')],
      [KeyVal(val: 'val')],
      [
        KeyVal(val: 'key='),
        KeyVal(val: 'val'),
        KeyVal(val: 'aaa'),
        KeyVal(val: 'bbb')
      ],
      [KeyVal(key: 'key', val: 'val ')],
      [KeyVal(key: 'k', val: 'v'), KeyVal(val: 'val2    ')],
      [KeyVal(val: 'val val2 val3')],
      [
        KeyVal(key: 'x y z', val: '123'),
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

  test("Globals are hoisted to the top in the output element list", () async {
    const doc = <String>[
      '1 key=val',
      '!a key=val',
      '2 val val',
      '!b',
      '3 key=val key2=val',
      '4 key=val',
      '!c val val key=val',
      '!d val, val',
      '5 key=val',
      '6 key=val',
      '!e key=val',
    ];

    const expected = <String>[
      '!a key=val',
      '!b',
      '!c val, val, key=val',
      '!d val, val',
      '!e key=val',
      '1 key=val',
      '2 val, val',
      '3 key=val, key2=val',
      '4 key=val',
      '5 key=val',
      '6 key=val',
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkDelimeterClosure(
          testName: 'Globals Hoist Test', values: expected),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });
}
