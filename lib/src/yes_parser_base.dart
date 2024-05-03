import 'dart:io';
import 'dart:convert';

import 'package:yes_parser/src/element.dart';
import 'package:yes_parser/src/element_parser.dart';
import 'package:yes_parser/src/enums.dart';

/// ErrorInfo
/// int line
/// String message
/// ErrorType type
///
/// This class represents a printable error info object with line numbers
class ErrorInfo {
  final int line;
  final String message;
  final ErrorType type;

  ErrorInfo(this.line, this.type) : message = type.message;

  // For runtime parsing issues unrelated to the YES spec itself
  const ErrorInfo.other(this.line, this.message) : type = ErrorType.runtime;

  @override
  String toString() {
    return '[Line $line] $message';
  }
}

/// Thennable is a future-like `then` construct for on-completed callbacks
typedef Thennable = void Function(List<Element>, List<ErrorInfo>);

/// YesParser
/// bool isComplete
///
/// This parser follows the YES specification to identify and extract Elements
/// from each line. The element list and any errors can be obtain by providing
/// a callback function to `then((elements, errors) {})`.
///
/// The parser can read asynchronously from a file using `YesParser.fromFile()`
/// To block and wait for the result, use `await parser.join()`
///
/// The parser can read from a String using `YesParser.fromString()`
/// This constructor performs synchronously and does not need to join.
///
/// Additionally you can check the getter `isComplete` for true.
class YesParser {
  final List<Element> _attrs = [];
  final List<Element> _elements = [];
  final List<ErrorInfo> _errors = [];
  int _lineCount = 0;
  Thennable? _onComplete;
  late Future<void> _future;
  bool _isComplete = false;

  bool get isComplete {
    return _isComplete;
  }

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
    _handleComplete();
    _future = Future.value();
  }

  void then(Thennable value) {
    _onComplete = value;
  }

  Future<void> join() async {
    await _future;
  }

  void _handleError(error, stackTrace) {
    _errors.add(ErrorInfo.other(_lineCount, error.toString()));
    _handleComplete();
  }

  void _handleComplete() {
    _onComplete?.call(_elements, _errors);
    _isComplete = true;
  }

  void _handleLine(String line) {
    _lineCount++;
    final p = ElementParser.read(_lineCount, line);

    if (!p.isOk) {
      _errors.add(ErrorInfo(_lineCount, p.error!));
      return;
    }

    switch (p.elementInfo.element.type) {
      case ElementType.attribute:
        _attrs.add(p.elementInfo.element);
        return;
      case ElementType.standard:
        p.elementInfo.element.setAttributes(_attrs);
        _attrs.clear();
        break;
      case _:
      /* fall-through */
    }

    _elements.add(p.elementInfo.element);
  }
}
