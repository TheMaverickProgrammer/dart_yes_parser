import 'dart:io';
import 'package:yes_parser/yes_parser.dart';

/// This example demonstrates how to parse a file using [YesParser]
/// and how to digest [ElementInfo] and [ErrorInfo] after parsing.
void main() async {
  final File file = File.fromUri(Uri.file("example/example.mesh"));

  final p = YesParser.fromFile(
    file,
    onComplete: printAll,
  );

  // Wait for parser to finish before ending program
  await p.join();
}

/// [Element] is the base class of each keyword. Upcasting is needed.
///
/// You can safely cast to the superclass type of the [ElementInfo.element] by
/// using [Element.isAttribute], [Element.isGlobal], [Element.isStandard], and
/// optionally [Element.isComment].
///
/// Only [Standard] elements can have [Attribute]s, which act as stackable
/// meta-data to add additional behaviors to your keywords.
void printAll(List<ElementInfo> elements, List<ErrorInfo> errors) {
  // Print every element
  for (final info in elements) {
    final Element el = info.element;
    // Print every attribute this standard element has
    if (el.isStandard) {
      for (final attr in (el as Standard).attrs) {
        print(attr);
      }

      /*
      // e.g. face texture = grass, name=f5
      if (el.name == "face") {
        final texture = el.getKeyValue("texture");
        final name = el.getKeyValue("name");
        // Do something with this data
      }
      */
    }
    print(el);
  }

  // Print errors with line numbers, if any
  for (final e in errors) {
    // Do not report empty lines
    if (e.type == ErrorType.eolNoData) continue;

    print('Error: $e');
  }
}
