import 'package:test/test.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/yes_parser.dart';

ParseCompleteFunc checkDelimeterClosure(
    {required List<String> values, List<String>? expectedErrors}) {
  return (List<ElementInfo> elements, List<ErrorInfo> errors) {
    //print(elements.map((e) => e.element));

    assert(values.length == elements.length,
        'Expected to have the same number of elements as values. Was: ${elements.length}. Expected: ${values.length})');

    if (expectedErrors != null) {
      assert(expectedErrors.length == errors.length,
          'Expected to have the same number of errors as values. Was: ${errors.length}. Expected: ${expectedErrors.length}');
    }
    final int len = values.length;
    for (int i = 0; i < len; i++) {
      final Element el = elements[i].element;
      expect(el.toString(), values[i],
          reason: 'Parsed element values[$i] did not match test string');
    }
  };
}

ParseCompleteFunc checkArgsClosure(
    {required List<List<KeyVal?>> values,
    List<String>? expectedErrors,
    dynamic matcher}) {
  return (List<ElementInfo> elements, List<ErrorInfo> errors) {
    //print(elements.map((e) => e.element));

    assert(values.length == elements.length,
        'Expected to have the same number of elements as values. Was: ${elements.length}. Expected: ${values.length})');

    if (expectedErrors != null) {
      assert(expectedErrors.length == errors.length,
          'Expected to have the same number of errors as values. Was: ${errors.length}. Expected: ${expectedErrors.length}');
    }
    final int len = values.length;
    for (int i = 0; i < len; i++) {
      final Element el = elements[i].element;
      final List<KeyVal?> args = values[i];

      final int argLen = args.length;
      expect(el.args.length, argLen,
          reason: 'Parsed args length is incorrect for i=$i');

      for (int j = 0; j < argLen; j++) {
        expect(el.args[j], matcher?.call(args[j]) ?? args[j],
            reason: 'Parsed KeyVal elements[$i] had unexpected args[$j] value');
      }
    }
  };
}

void main() {
  test("Delimiter detection test", () async {
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
    ];

    const expected = <String>[
      'a key=val',
      'b val, val2',
      'c val',
      'd key=val',
      'e key=val',
      'f key=val',
      'g key=val aaa bbb',
      'h key=val',
      'i key=val, key2=val2',
      'j key=val, key2=val2',
      'k key=val, val2 aaa',
      'l key=val, key2=val2',
      'm val',
      'n key=',
      'o key=',
      'p key=',
      'q',
      'r key=val, key2=val2, key3=val3',
      's val, val2, val3',
      't key=val, key2=val2, key3=val3',
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkDelimeterClosure(values: expected),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });

  test("Parse KeyVal succeed test", () async {
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
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkArgsClosure(values: expected),
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
    ];

    final p = YesParser.fromString(
      doc.join('\n'),
      onComplete: checkArgsClosure(values: isNotExpected, matcher: isNot),
    );

    // Wait for parser to finish before ending program
    await p.join();
  });
}
