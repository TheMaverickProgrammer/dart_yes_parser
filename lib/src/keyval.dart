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
  KeyVal({this.key, required this.val});

  bool get isNameless {
    return key == null;
  }

  @override
  String toString() {
    if (isNameless) {
      return val;
    }

    return '${key!}=$val';
  }
}
