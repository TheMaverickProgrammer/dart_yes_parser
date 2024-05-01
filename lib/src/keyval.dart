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
