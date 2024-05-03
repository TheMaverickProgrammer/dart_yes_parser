import 'dart:io';
import 'package:yes_parser/yes_parser.dart';

/// This example demonstrates how to parse a file using the YES spec
/// And how to report errors after parsing.

void main() async {
  final p = YesParser.fromFile(File.fromUri(Uri.file("test.anim")))
    ..then(printAll);

  // Wait for parser to finish before ending program
  await p.join();
}

void printAll(List<Element> elements, List<ErrorInfo> errors) {
  // Print every element
  for (final el in elements) {
    // Print every attribute this element has
    for (final attr in el.attrs) {
      print(attr);
    }
    print(el);
  }

  // Print errors with line numbers, if any
  for (final e in errors) {
    // Do not report empty lines (new lines)
    if (e.type == ErrorType.eolNoData) continue;

    print('Error: $e');
  }
}
