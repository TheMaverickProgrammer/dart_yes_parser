import 'dart:io';
import 'dart:convert';

import 'package:yes_parser/src/element.dart';
import 'package:yes_parser/src/element_parser.dart';
import 'package:yes_parser/src/enums.dart';

/// [ErrorInfo] has the offending [line] and reason [message].
/// [type] can be pattern matched with one of the hard-coded [ErrorType]s.
///
/// Constructor [ErrorInfo.other] sets [type] to [ErrorType.runtime] which
/// can be used for your own custom error [message]s.
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

/// [ElementInfo] has the [line] which parsed it and the result [Element].
/// Knowing the [line] is useful because other parsers using this spec may need
/// to raise additional errors if elements in their doc are missing specific
/// [Standard.args] or have malformed values.
class ElementInfo {
  final int line;
  final Element element;

  ElementInfo(this.line, this.element);
}

/// [ParseCompleteFunc] is for on-completed callbacks
typedef ParseCompleteFunc = void Function(List<ElementInfo>, List<ErrorInfo>);

/// This parser follows the YES sepc to identify and extract [Element]s
/// from each line. The [Element] list and any errors [ErrorInfo] can be
/// obtained by providing a callback function to [onComplete].
///
/// The parser can read asynchronously from a file using [YesParser.fromFile].
/// To block and wait for the result, await [YesParser.join].
///
/// The parser can read a document's contents using [YesParser.fromString].
/// This constructor performs synchronously and does not need a call to [join].
///
/// Additionally you can check the status via the getter [isComplete].
class YesParser {
  final List<Attribute> _attrs = [];
  final List<ElementInfo> _elements = [];
  final List<ErrorInfo> _errors = [];
  int _lineCount = 0;
  ParseCompleteFunc? _onComplete;
  late Future<void> _future;
  bool _isComplete = false;

  /// If false, the parser is not finished. True otherwise.
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

  YesParser.fromString(String contents) {
    contents.split('\n').forEach((line) => _handleLine(line));
    _handleComplete();
    _future = Future.value();
  }

  void onComplete(ParseCompleteFunc func) {
    _onComplete = func;
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
        _attrs.add(p.elementInfo.element as Attribute);
        return;
      case ElementType.standard:
        (p.elementInfo.element as Standard).setAttributes(_attrs);
        _attrs.clear();
        _elements.add(ElementInfo(_lineCount, p.elementInfo.element));
      case _:
        _elements.add(ElementInfo(_lineCount, p.elementInfo.element));
    }
  }
}
