enum Delimiters {
  unset(0),
  spaceComma(1),
  spaceOnly(2);

  final int value;
  const Delimiters(this.value);
}

enum Elements {
  standard(''),
  attribute('@'),
  global('!'),
  comment('#');

  final String symbol;
  const Elements(this.symbol);
}

enum Glyphs {
  none(''),
  equal('='),
  at('@'),
  bang('!'),
  hash('#'),
  space(' '),
  comma(','),
  quote(r'"');

  final String char;
  const Glyphs(this.char);
}

enum YesSpecErrors {
  badTokenPosAttribute('Element using attribute prefix out-of-place.'),
  badTokenPosBang('Element using global prefix out-of-place.'),
  eolNoData('Nothing to parse (EOL).'),
  eolMissingElement('Missing element name (EOL).'),
  eolMissingAttribute('Missing attribute name (EOL).'),
  eolMissingGlobal('Missing global identifier (EOL).'),
  unterminatedQuote('Missing end quote in expression.'),
  runtime('Unexpected runtime error.'); // Reserved for misc. parsing issues

  final String message;
  const YesSpecErrors(this.message);

  @override
  String toString() => message;
}
