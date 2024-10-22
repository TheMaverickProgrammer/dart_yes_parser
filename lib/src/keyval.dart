/// [KeyVal] represents a [key] and its [String] value [val].
///
/// A [key] can be `null` and is called a nameless [KeyVal]. Such [KeyVal]s
/// will return `true` for the getter [isNameless].
///
/// The data [val] is always stored internally as a [String] with any quotes
/// read from the document. Quotes are stripped when the value is fetched
/// by the Element class. If you expect quotes to be retained, use the
/// [String] extensions provided by this package.
class KeyVal {
  final String? key;
  final String val;
  final bool _keyContainsSpace;
  final bool _valContainsSpace;
  KeyVal({this.key, required this.val})
      : _keyContainsSpace = key?.contains(' ') ?? false,
        _valContainsSpace = val.contains(' ');

  bool get isNameless {
    return key == null;
  }

  @override
  String toString() {
    final String v = switch (_valContainsSpace) {
      true => '"$val"',
      false => val,
    };

    if (isNameless) {
      return v;
    }

    final String k = switch (_keyContainsSpace) {
      true => '"${key!}"',
      false => key!,
    };

    return '$k=$v';
  }

  @override
  int get hashCode => Object.hash(key.hashCode, val.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is! KeyVal) return false;

    return other.key == key && other.val == val;
  }
}
