import 'package:yes_parser/src/enums.dart';

/// User-provided [begin] and [end] glyphs to associate with a spanned
/// string literal while parsing an [Element]'s [KeyVal] pairs.
class Literal {
  final String begin;
  final String end;

  const Literal({required this.begin, required this.end})
      : assert(begin != r' ' && begin != r',' && begin != r'=' && begin != r'\',
            'Literal cannot begin with a reserved character.'),
        assert(end != r' ' && end != r',' && end != r'=' && end != r'\',
            'Literal cannot end with a reserved character.');

  factory Literal.quotes() {
    return Literal(begin: Glyphs.quote.char, end: Glyphs.quote.char);
  }
}
