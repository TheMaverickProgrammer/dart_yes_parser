import 'dart:io';
import 'package:yes_parser/yes_parser.dart';

/// This example demonstrates how to parse a file using the YES spec
/// And how to report errors after parsing.

void main() async {
  final p = YesParser.fromFile(File.fromUri(Uri.file("example/example.mesh")))
    ..onComplete(printAll);

  // Wait for parser to finish before ending program
  await p.join();
}

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
    // Do not report empty lines (new lines)
    if (e.type == ErrorType.eolNoData) continue;

    print('Error: $e');
  }
}
