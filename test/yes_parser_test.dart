import 'package:test/test.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/yes_parser.dart';

void checkDelimeter(
  String testName, {
  required List<ElementInfo> elements,
  required List<ErrorInfo> errors,
  required List<String> expectedValues,
  List<String>? expectedErrors,
}) {
  expect(
    expectedValues.length,
    elements.length,
    reason: '[$testName] Expected elements and expected values to be equal.'
        '\nWas: ${elements.length}. Expected: ${expectedValues.length})',
  );

  if (expectedErrors != null) {
    expect(
      expectedErrors.length,
      errors.length,
      reason:
          '[$testName] Expected to have the same number of errors as expected values.'
          '\nWas: ${errors.length}. Expected: ${expectedErrors.length}',
    );
  }

  final int len = expectedValues.length;
  for (int i = 0; i < len; i++) {
    final Element el = elements[i].element;
    expect(el.toString(), expectedValues[i],
        reason:
            '[$testName] Parsed element expectedValues[$i] did not match test string');
  }
}

void checkArgs(
  String testName, {
  required List<ElementInfo> elements,
  required List<ErrorInfo> errors,
  required List<List<KeyVal?>> expectedValues,
  List<String>? expectedErrors,
  dynamic matcher,
}) {
  expect(
    expectedValues.length,
    elements.length,
    reason: '[$testName] Expected elements and expected values to be equal.'
        '\nWas: ${elements.length}. Expected: ${expectedValues.length})',
  );

  if (expectedErrors != null) {
    expect(
      expectedErrors.length,
      errors.length,
      reason:
          '[$testName] Expected to have the same number of errors as expected values.'
          '\nWas: ${errors.length}. Expected: ${expectedErrors.length}',
    );
  }

  final int len = expectedValues.length;
  for (int i = 0; i < len; i++) {
    final Element el = elements[i].element;
    final List<KeyVal?> args = expectedValues[i];

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
      'y\tz\ty2\t\tz2\t\t',
      'z a\t=\t1,b\t=\t2'
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
      'y z, y2, z2',
      'z a=1, b=2'
    ];

    final parser = YesParser.fromString(doc.join('\n'));

    checkDelimeter(
      'Delimiter Test',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });

  test("KeyVal quoted keys and values are parsed without quotes", () async {
    const doc = <String>[
      'a "aaa bbb"',
      'b "crab battle" "efficient car goose" "key3"="value3" "key4"=value4 "value5"',
      'c "1234"',
      'd "\t\tez\t\t"'
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
      [KeyVal(val: '\t\tez\t\t')]
    ];

    final docStr = doc.join('\n');
    final parser = YesParser.fromString(
      docStr,
    );

    checkArgs(
      'Quoted Test',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expectedNotQuoted,
    );
  });

  test("KeyVals parse correctly", () async {
    const doc = <String>[
      'a key = val',
      'b    val      val2    val3    ',
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
      'let1 x: int = 4',
      'let2 x: int=32'
    ];

    final expected = <List<KeyVal>>[
      [KeyVal(key: 'key', val: 'val')],
      [KeyVal(val: 'val'), KeyVal(val: 'val2'), KeyVal(val: 'val3')],
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
      [
        KeyVal(val: 'x:'),
        KeyVal(val: 'int'),
        KeyVal(val: '4'),
      ],
      [
        KeyVal(val: 'x:'),
        KeyVal(key: 'int', val: '32'),
      ],
    ];

    final parser = YesParser.fromString(doc.join('\n'));

    checkArgs(
      'Parse Test',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
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

    final parser = YesParser.fromString(
      doc.join('\n'),
    );

    checkArgs(
      'Sanity Check',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: isNotExpected,
      matcher: isNot,
    );
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

    final parser = YesParser.fromString(doc.join('\n'));

    checkDelimeter(
      'Globals Hoist Test',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });

  test("Macro-like strings", () async {
    const doc = <String>[
      '!macro teardown_textbox(tb) = "call common.textbox_teardown tb="tb',
    ];

    final expected = <List<KeyVal?>>[
      [
        KeyVal(
          key: 'teardown_textbox(tb)',
          val: '"call common.textbox_teardown tb="tb',
        ),
      ],
    ];

    final parser = YesParser.fromString(doc.join('\n'));

    checkArgs(
      'Macro-like string args',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });

  test("Multi-line elements", () async {
    const doc = <String>[
      'var msg: str="apple, bananas, coconut, diamond, eggplant\\',
      ', fig, grape, horse, igloo, joke, kangaroo\\',
      ', lemon, notebook, mango"',
      'var list2: [int]=[1\\',
      ', 2, 3, 4, 5, 6, 7]',
    ];

    final expected = <List<KeyVal?>>[
      [
        KeyVal(
          val: 'msg:',
        ),
        KeyVal(
          key: 'str',
          val: 'apple, bananas, coconut, diamond, eggplant'
              ', fig, grape, horse, igloo, joke, kangaroo'
              ', lemon, notebook, mango',
        ),
      ],
      [
        KeyVal(
          val: 'list2:',
        ),
        KeyVal(
          key: '[int]',
          val: '[1, 2, 3, 4, 5, 6, 7]',
        ),
      ],
    ];

    final parser = YesParser.fromString(
      doc.join('\n'),
      literals: [
        Literal(
          begin: '[',
          end: ']',
        ),
      ],
    );

    checkArgs(
      'Mult-line elements',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });

  test("Tab-as-whitespace test", () async {
    const doc = <String>[
      'a b\tc',
      'e\tf\tg',
      'm n="\t\to\t\t"\tp',
      'scenes act/level1.dev\\',
      '       act/level2.dev\\',
      '       act/level3.dev',
    ];

    final expected = <List<KeyVal?>>[
      [
        KeyVal(
          val: 'b',
        ),
        KeyVal(
          val: 'c',
        ),
      ],
      [
        KeyVal(
          val: 'f',
        ),
        KeyVal(
          val: 'g',
        ),
      ],
      [
        KeyVal(
          key: 'n',
          val: '\t\to\t\t',
        ),
        KeyVal(
          val: 'p',
        ),
      ],
      [
        KeyVal(
          val: 'act/level1.dev',
        ),
        KeyVal(
          val: 'act/level2.dev',
        ),
        KeyVal(
          val: 'act/level3.dev',
        ),
      ],
    ];

    final parser = YesParser.fromString(
      doc.join('\n'),
      literals: [
        Literal(
          begin: '[',
          end: ']',
        ),
      ],
    );

    checkArgs(
      'Tabs-as-whitespace Test',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });

  test("Literals", () async {
    const String line = "fn hello_world: (&int num, str message) {}";

    final expected = <List<KeyVal?>>[
      [
        KeyVal(
          val: 'hello_world:',
        ),
        KeyVal(
          val: '(&int num, str message)',
        ),
        KeyVal(val: '{}'),
      ],
    ];

    final parser = YesParser.fromString(
      line,
      literals: [
        Literal(
          begin: '(',
          end: ')',
        ),
        Literal(
          begin: '{',
          end: '}',
        ),
      ],
    );

    checkArgs(
      'Literals',
      elements: parser.elementInfoList,
      errors: parser.errorInfoList,
      expectedValues: expected,
    );
  });
}
