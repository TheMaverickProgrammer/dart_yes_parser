/// Identifies which delimiter is used for parsing a line.
enum Delimiters {
  unset,
  comma,
  space;
}

/// Spec-compliant tokens. The token is stored in [symbol].
enum ElementType {
  standard(''),
  attribute('@'),
  global('!'),
  comment('#'),
  multiline(r'\');

  final String symbol;
  const ElementType(this.symbol);
}

/// Spec-reserved glyphs use while parsing. The character is stored in [char].
enum Glyphs {
  none(''),
  equal('='),
  at('@'),
  bang('!'),
  hash('#'),
  space(' '),
  comma(','),
  quote(r'"'),
  backslash(r'\'),
  tab('\t');

  final String char;
  const Glyphs(this.char);
}

/// Spec-specific [ErrorType]s with a [message].
/// [ErrorType.runtime] is provided for implemntations that need custom errors.
enum ErrorType {
  badTokenPosAttribute('Element using attribute prefix out-of-place.'),
  badTokenPosBang('Element using global prefix out-of-place.'),
  eolNoData('Nothing to parse (EOL).'),
  eolMissingElement('Missing element name (EOL).'),
  eolMissingAttribute('Missing attribute name (EOL).'),
  eolMissingGlobal('Missing global identifier (EOL).'),
  unterminatedQuote('Missing end quote in expression.'),
  runtime('Unexpected runtime error.'); // Reserved for misc. parsing issues

  final String message;
  const ErrorType(this.message);

  @override
  String toString() => message;
}
