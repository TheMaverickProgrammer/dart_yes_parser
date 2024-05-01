import 'dart:io';

import 'package:yes_parser/yes_parser.dart';

void main() async {
  final p = YesParser.fromFile(File.fromUri(Uri.file("test.anim")))
    ..then((List<Element> elements, List<String> errors) {
      for (final Element el in elements) {
        print(el);
      }

      // Errors:
      for (final String e in errors) {
        print(e);
      }
    });

  await p.join();
}
