import 'dart:collection';

import 'package:yes_parser/extensions.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/src/enums.dart';

/// [Element] is base of [Attribute], [Standard], [Global], and [Comment].
///
/// It has a [text] field which is used directly by [Comment].
/// The other types use alias [Attribute.name], [Standard.name], [Global.name].
/// Elements have zero or more [args] where each entry is a [KeyVal] object.
/// This base class exposes methods to [add], [upsert], and query keys.
///
/// [hasKey] and [hasKeys] return true iff this [Element]'s [args] have all
/// key names passed into them. If any one fails, then the return is false.
///
/// [getKeyValue] returns [String]? and is the internal type of [KeyVal.val].
/// [getKeyValueAsInt] returns 0 if not found or value [or] if provided.
/// [getKeyValueAsBool] returns false if not found or value [or] if provided.
/// [getKeyValueAsDouble] returns 0.0 if not found or value [or] if provided.
/// [toString] is overloaded to print the glyph, element name, and all [args].
class Element {
  final String text;
  final ElementType type;
  final List<KeyVal> _args = [];

  // Private constructor
  Element._(this.type, this.text);

  /// Create a standard element named [label];
  factory Element.standard(String label) => Standard(label);

  /// Create an attribute element named [label]
  factory Element.attribute(String label) =>
      Attribute.from(Element._(ElementType.attribute, label));

  /// Create a global element named [label]
  factory Element.global(String label) =>
      Global.from(Element._(ElementType.global, label));

  /// Create a line comment element from [text]
  factory Element.comment(String text) =>
      Comment.from(Element._(ElementType.comment, text));

  // Shorthand type checks
  bool get isStandard => type == ElementType.standard;
  bool get isAttribute => type == ElementType.attribute;
  bool get isGlobal => type == ElementType.global;
  bool get isComment => type == ElementType.comment;

  /// Get immutable list of [KeyVal]
  UnmodifiableListView<KeyVal> get args {
    return UnmodifiableListView(_args);
  }

  /// Add a new [KeyVal]
  void add(KeyVal kv) {
    _args.add(kv);
  }

  /// Finds and updates [KeyVal] by its [KeyVal.key]
  /// Inserts if not found or [KeyVal.isNameless] is true.
  void upsert(KeyVal kv) {
    final int idx = _args.indexWhere((e) => !e.isNameless && e == kv);

    // Insert if no match was found
    if (idx == -1) {
      add(kv);
      return;
    }

    // Update
    _args[idx] = kv;
  }

  /// Returns true if the element has a [KeyVal] with the same [key].
  /// Case-insensitive.
  bool hasKey(String key) {
    final int idx =
        _args.indexWhere((el) => el.key?.toLowerCase() == key.toLowerCase());
    return idx > -1;
  }

  /// Returns true if the element has ALL keys of the same key string.
  /// Useful for ensuring custom standard elements have all required keyvalues.
  /// Case-insensitive.
  bool hasKeys(List<String> keys) {
    for (final String key in keys) {
      final int idx =
          _args.indexWhere((el) => el.key?.toLowerCase() == key.toLowerCase());
      if (idx == -1) return false;
    }
    return true;
  }

  /// Return [KeyVal.val] as String or null.
  /// Optional [or] value when key is null or unable to parse.
  /// Case-insensitive.
  String? getKeyValue(String key, [String? or]) {
    final int idx =
        _args.indexWhere((el) => el.key?.toLowerCase() == key.toLowerCase());

    // Found
    if (idx != -1) {
      return _args[idx].val;
    }

    // Miss
    return or;
  }

  /// Return [KeyVal.val] as int.
  /// Optional [or] value when key is null or unable to parse.
  /// Default behavior for null values is to return 0.
  /// Case-insensitive.
  int getKeyValueAsInt(String key, [int? or]) {
    final val = getKeyValue(key);
    return int.tryParse(val ?? '') ?? or ?? 0;
  }

  /// Return [KeyVal.val] as bool.
  /// Optional [or] value when key is null or unable to parse.
  /// Default behavior for null values is to return false.
  /// If a number is provided, 0 is false, and everything else is true.
  /// If a string is provided, it will be compared to "true".
  /// Case-insensitive.
  bool getKeyValueAsBool(String key, [bool? or]) {
    final val = getKeyValue(key);

    int? asInt;

    if (val != null) {
      asInt = int.tryParse(val);
    }

    if (asInt == null) {
      // Value was not encoded as a number. Try boolean.
      return bool.tryParse(val ?? '', caseSensitive: false) ?? or ?? false;
    }

    // Any non-zero number is a truthy value while zero is false.
    return asInt != 0;
  }

  /// Return [KeyVal.val] as double.
  /// Optional [or] value when key is null or unable to parse.
  /// Default behavior for null values is to return 0.0.
  /// Case-insensitive.
  double getKeyValueAsDouble(String key, [double? or]) {
    final val = getKeyValue(key);
    return double.tryParse(val ?? '') ?? or ?? 0.0;
  }

  @override
  String toString() {
    return "${type.symbol}$text${_args.isNotEmpty ? ' ' : ''}${_printArgs()}";
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

/// [Attribute] extension type wraps [Element] to distinguish them.
extension type Attribute._(Element _detail) implements Element {
  /// [Attribute] elements have a [name].
  String get name => text;

  Attribute.from(Element element)
      : assert(element.isAttribute, "Expected ElementType.Attribute"),
        _detail = element;
}

/// [Global] extension type wraps [Element] to distinguish them.
extension type Global._(Element _detail) implements Element {
  /// [Global] elements have a [name].
  String get name => text;

  Global.from(Element element)
      : assert(element.isGlobal, "Expected ElementType.Global"),
        _detail = element;
}

/// [Comment] extension type wraps [Element] to distinguish them.
extension type Comment._(Element _detail) implements Element {
  Comment.from(Element element)
      : assert(element.isComment, "Expected ElementType.Comment"),
        _detail = element;
}

/// [Standard] elements are unique in that they carry metadata.
final class Standard extends Element {
  /// [Standard] elements have zero or more [Attribute]s.
  final List<Attribute> _attrs = [];

  /// [Standard] elements have a [name] field.
  String get name => text;

  /// Construct a new [Standard] object with a [name].
  Standard(String name) : super._(ElementType.standard, name);

  /// Get immutable list of attributes embeded to this element
  UnmodifiableListView<Attribute> get attrs {
    return UnmodifiableListView(_attrs);
  }

  /// Clears and replaces attributes with the incoming [List].
  void setAttributes(List<Attribute> attrs) {
    _attrs
      ..clear()
      ..addAll(attrs);
  }
}
