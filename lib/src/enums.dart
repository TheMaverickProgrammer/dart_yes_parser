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

  final String value;
  const Elements(this.value);
}

enum Glyphs {
  equal('='),
  attribute('@'),
  bang('!'),
  hash('#'),
  space(' '),
  comma(','),
  quote(r'"');

  final String value;
  const Glyphs(this.value);
}
