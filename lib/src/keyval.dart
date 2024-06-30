/// KeyVal
/// String? key
/// String val
/// bool isNamesless
///
/// KeyVal represent YES spec keyvalues.
/// `key` can be null, representing Nameless Keyvalues.
/// `val` is stored as a String internally.
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
