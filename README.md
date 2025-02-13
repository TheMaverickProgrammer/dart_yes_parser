# YES Script
`YES` - **Y**our **E**xtensible **S**cript .

Do you want a custom and simple file format but don't want to code the parser?
**YES** is the answer! ✨

YES is a meta scriplet standard whose elements, keys, and evaluation
are yours to decide. YES-defined elements can have optional **attributes**
which tag to elements in order to extend their behavior further. This has been
proven useful in products which needed to provide UGC (User Generated Content).

> [!TIP]
> Read the [scriptlet standard][SPEC] to learn more.

### Use Cases
Your data can mean anything. 
The parsing is done so the logic is up to you. 

YES-compliant parsers can be used:
  - to define [animation][BOOMFLAME] files
  - as an extended [.OBJ][WAVEFRONT] wavefront 3D model format
  - as an extended [.INI][INI] dialect
  - as a configuration file
  - to implement a scripting language
  - to represent character dialog
  - to implement a simple network protocol
  - *and more*

## Getting Started
This pub provides `YesDocParser` with two static methods:
  1. `Future<YesParser> fromFile(File file, {List<Literal>? literals})` 
     1. Call to parse by file asynchronously 
  2. `YesParser fromString(String contents, {List<Literal>? literals})`
     1. Call to parse by string

Even if no argument is supplied for `literals`, the parser will add a pair of
quotes for you as the first literal pair to check against while reading.

See [`Literal.quotes()`][LITERAL_QUOTES].

#### Optional Literals
Literals are character pairs which instructs the parser to take every
subsequent character in the buffer from `Literal.begin` to `Literal.end`.

This allows even further extension of the format for your own documents.
For example, consider the following line:

`var x: [int] = [0, 1, 2, 3, 4, 5]`

By providing a custom literal pair `[` and `]`, the span `[0, 1, 2, 3, 4, 5]`
will be stored in the argument `[int]` which then allows a programmer
to easily determine if that value is correctly notated as an integer array.

Here's how to provide a list of custom literals:

```rs
final List<Literal> literals = [ 
  Literal(begin: '[', end: ']'),
];

final parser = YesDocParser.fromString(content, literals);

for(final element in parser.elementInfoList) {
  // ...
}
```

#### Multiline Support
The spec is intended to be simple. 
Simple to read.
Simple to write.
Simple to parse.

Therefore newlines `\n` were chosen to denote the end of an element.
This may not appeal to programmers who are used to bracket notation
or semicolons, however non-programmers will appreciate the simplicity.

While simplicity is desired, presentation is just as important.

Elements whose line end with the backslash `\` character will defer reading
until the last line without the backslash terminator. This allows documents
to support elements with arguments which span several lines.

Example:
```js
var long_message: str="\
      apple, bananas, coconut, diamond, eggplant,\
      fig, grape, horse, igloo, joke, kangaroo,\
      lemon, notebook, mango"
```

### Simple Start
Here is a very simple example to show you how to get started:

```dart
final String content = "frame duration = 1.0s , width = 10, height=20";
final YesDocParser parser = YesDocParser.fromString(content);
final Element data = parser.elementInfoList.first.element;

final String duration = data.getKeyValue("duration", /*or*/ "0s");
final int width = data.getKeyValueAsInt("width", /*or*/ 0);
final int height = data.getKeyValueAsInt("height", /*or*/ 0);

assert(duration == "1.0s");
assert(width == 10);
assert(height == 20);
```

> [!WARNING]
> Be mindful and validate your own document formats!

## License
This project is licensed under the [Common Development and Distribution License (CDDL)][LEGAL].

[BOOMFLAME]: https://github.com/TheMaverickProgrammer/boomflame
[EXAMPLE]: ./example/yes_parser_example.dart
[INI]: https://en.wikipedia.org/wiki/INI_file
[LEGAL]: https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/LICENSE
[LITERAL_QUOTES]: ./lib/src/literal.dart
[SPEC]: https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/spec/README.md
[WAVEFRONT]: https://en.wikipedia.org/wiki/Wavefront_.obj_file