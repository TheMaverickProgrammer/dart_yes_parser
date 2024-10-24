import 'dart:io';
import 'dart:convert';

import 'package:yes_parser/src/element.dart';
import 'package:yes_parser/src/element_parser.dart';
import 'package:yes_parser/src/enums.dart';

/// [ErrorInfo] has the offending [line] and reason [message].
///
/// [type] can be pattern matched with one of the hard-coded [ErrorType]s.
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

/// [ParseCompleteFunc] is for on-completed callbacks
typedef ParseCompleteFunc = void Function(List<ElementInfo>, List<ErrorInfo>);

/// This parser follows the YES spec to extract [Element]s from each line.
///
/// The [Element] list and any errors [ErrorInfo] can be obtained by
/// [elementInfoList] and [errorInfoList] respectively.
///
/// The parser can read asynchronously from a file using [YesParser.fromFile].
///
/// The parser can read a document's contents using [YesParser.fromString].
class YesParser {
  int _lineCount = 0;
  final List<Attribute> _attrs = [];
  final List<ElementInfo> elementInfoList = [];
  final List<ErrorInfo> errorInfoList = [];

  YesParser();

  static Future<YesParser> fromFile(File file) async {
    final YesParser parser = YesParser();
    await file
        .openRead()
        .transform(utf8.decoder)
        .transform(LineSplitter())
        .forEach((line) => parser._handleLine(line))
        .onError(parser._handleError)
        .then((_) => parser._handleComplete());

    return parser;
  }

  static YesParser fromString(String contents) {
    final YesParser parser = YesParser();

    contents.split('\n').forEach((line) => parser._handleLine(line));
    parser._handleComplete();

    return parser;
  }

  void _handleError(error, stackTrace) {
    errorInfoList.add(ErrorInfo.other(_lineCount, error.toString()));
    _handleComplete();
  }

  void _handleComplete() {
    // Hoist globals to the top of the list in order they were entered.
    elementInfoList.sort(
      (a, b) => switch ((a.element.type, b.element.type)) {
        (ElementType.global, ElementType.global) =>
          a.lineNumber.compareTo(b.lineNumber),
        (ElementType.global, _) => -1,
        (_, ElementType.global) => 1,
        (_, _) => a.lineNumber.compareTo(b.lineNumber),
      },
    );
  }

  void _handleLine(String line) {
    _lineCount++;
    final ElementParser elementParser = ElementParser.read(_lineCount, line);

    if (!elementParser.isOk) {
      errorInfoList.add(ErrorInfo(_lineCount, elementParser.error!));
      return;
    }

    final ElementInfo info = elementParser.elementInfo;

    switch (info.element.type) {
      case ElementType.attribute:
        // Per the spec, collect attributes to assign them to the
        // next standard element.
        _attrs.add(info.element as Attribute);
        return;
      case ElementType.standard:
        // Flush collected attributes into this standard element.
        (info.element as Standard).setAttributes(_attrs);
        _attrs.clear();
        elementInfoList.add(ElementInfo(_lineCount, info.element));
      case _:
        elementInfoList.add(ElementInfo(_lineCount, info.element));
    }
  }
}
