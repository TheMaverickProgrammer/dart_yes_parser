import 'dart:io';
import 'dart:convert';

import 'package:yes_parser/src/element.dart';
import 'package:yes_parser/src/element_parser.dart';

typedef Thennable = void Function(List<Element>, List<String>);

class YesParser {
  List<Element> elements = [];
  List<String> errors = [];
  int lineCount = 0;
  Thennable? _onComplete;
  late Future<void> _future;

  YesParser.fromFile(File file) {
    _future = file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) => _handleLine(line))
        .onError(_handleError)
        .then((_) => _handleComplete());
  }

  YesParser.fromString(String source) {
    source.split('\n').forEach((line) => _handleLine(line));
    _onComplete?.call(elements, errors);
    _future = Future.value();
  }

  void then(Thennable value) {
    _onComplete = value;
  }

  Future<void> join() async {
    await _future;
  }

  void _handleError(error, stackTrace) {
    errors.add(error.toString());
    errors.add(stackTrace.toString());
    _handleComplete();
  }

  void _handleComplete() {
    _onComplete?.call(elements, errors);
  }

  void _handleLine(String line) {
    lineCount++;
    final p = ElementParser.read(line);

    if (!p.isOk) {
      errors.add("[$lineCount]: ${p.error}");
      return;
    }

    elements.add(p.element);
  }
}
