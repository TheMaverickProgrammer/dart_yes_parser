/// User-provided [begin] and [end] glyphs to associate with a spanned
/// string literal while parsing an [Element]'s [KeyVal] pairs.
class Literal {
  final String begin;
  final String end;

  const Literal({required this.begin, required this.end});
}
