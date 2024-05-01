import 'dart:collection';

import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/src/enums.dart';

class Element {
  final String text;
  final Elements type;
  final List<KeyVal> _args = [];

  Element.standard(String label)
      : type = Elements.standard,
        text = label;

  Element.attribute(String label)
      : type = Elements.attribute,
        text = label;

  Element.global(String label)
      : type = Elements.global,
        text = label;

  Element.comment(this.text) : type = Elements.comment;

  UnmodifiableListView<KeyVal> get args {
    return UnmodifiableListView(_args);
  }

  void add(KeyVal kv) {
    _args.add(kv);
  }

  void upsert(KeyVal kv) {
    final int idx = _args.indexWhere((el) => el == kv);

    // Insert if no match was found
    if (idx == -1) {
      add(kv);
      return;
    }

    // Update
    _args[idx] = kv;
  }

  String? getKeyValue(String key) {
    final int idx = _args.indexWhere((el) => el.key == key);

    // Found
    if (idx != -1) {
      return _args[idx].val;
    }

    // Miss
    return null;
  }

  @override
  String toString() {
    return "${type.symbol}$text ${_printArgs()}";
  }

  String _printArgs() {
    String res = '';
    final int len = _args.length;
    for (int i = 0; i < len; i++) {
      res += _args[i].toString();
      if (i < len - 1) {
        res += ', ';
      }
    }

    return res;
  }
}
