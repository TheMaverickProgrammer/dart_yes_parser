import 'dart:collection';

import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/src/enums.dart';

class Element {
  final String text;
  final Elements type;
  final List<KeyVal> _args = [];
  final List<Element> _attrs = [];

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

  /// Get immutable list of keyvalues
  UnmodifiableListView<KeyVal> get args {
    return UnmodifiableListView(_args);
  }

  /// Get immutable list of attributes embeded to this element
  UnmodifiableListView<Element> get attrs {
    return UnmodifiableListView(_attrs);
  }

  /// Overrides embeded attributes
  void setAttributes(List<Element> attrs) {
    _attrs.clear();
    for (final a in attrs) {
      if (a.type != Elements.attribute) {
        throw Exception('Element is not an attribute!');
      }
      _attrs.add(a);
    }
  }

  /// Add a new keyvalue
  void add(KeyVal kv) {
    _args.add(kv);
  }

  /// Finds and updates keyvalue by name
  /// Or inserts if nameless
  void upsert(KeyVal kv) {
    final int idx = _args.indexWhere((el) => !el.isNameless && el == kv);

    // Insert if no match was found
    if (idx == -1) {
      add(kv);
      return;
    }

    // Update
    _args[idx] = kv;
  }

  /// Return value as String or null
  /// (Optional) `or` value when key is null or unable to parse.
  String? getKeyValue(String key, [String? or]) {
    final int idx = _args.indexWhere((el) => el.key == key);

    // Found
    if (idx != -1) {
      return _args[idx].val;
    }

    // Miss
    return or;
  }

  /// Return value as int
  /// (Optional) `or` value when key is null or unable to parse.
  /// Default behavior for null values is to return 0.
  int getKeyValueAsInt(String key, [int? or]) {
    final val = getKeyValue(key);
    return int.tryParse(val ?? '') ?? or ?? 0;
  }

  /// Return value as bool
  /// (Optional) `or` value when key is null or unable to parse.
  /// Default behavior for null values is to return false.
  bool getKeyValueAsBool(String key, [bool? or]) {
    final val = getKeyValue(key);
    return bool.tryParse(val ?? '') ?? or ?? false;
  }

  /// Return value as double
  /// (Optional) `or` value when key is null or unable to parse.
  /// Default behavior for null values is to return 0.0.
  double getKeyValueAsDouble(String key, [double? or]) {
    final val = getKeyValue(key);
    return double.tryParse(val ?? '') ?? or ?? 0.0;
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
