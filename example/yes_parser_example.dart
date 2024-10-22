import 'dart:io';
import 'package:yes_parser/yes_parser.dart';

/// This example demonstrates how to parse a file using [YesParser]
/// and how to digest [ElementInfo] and [ErrorInfo] after parsing.
void main() async {
  final File file = File.fromUri(Uri.file("doc.mesh"));
  final YesParser parser = await YesParser.fromFile(file);

  printAll(parser.elementInfoList, parser.errorInfoList);
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
