/// Extends [String] for convenience
extension YesStringExtensions on String {
  /// Returns true if first and last char are a double quote (")
  bool get isQuoted =>
      length > 1 && this[0] == "\"" && this[length - 1] == "\"";

  /// Returns a new [String] wrapped in double quotes or itself if quoted.
  String quote() => !isQuoted ? "\"$this\"" : this;

  /// Returns a new [String] without outer-quotes or itself if not quoted.
  String unquote() => isQuoted ? substring(1, length - 1) : this;
}
