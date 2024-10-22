# YES Script
`YES` - **Y**our **E**xtensible **S**cript .

Do you want a custom and simple file format but don't want to code the parser?
**YES** is the answer! ✨

YES is a meta scriplet standard whose elements, keys, and evaluation
are yours to decide. These scriplets are used for configuration files,
animation documents, tiny scripting, and then some. YES has optional 
**attribute** support to tag elements and extend their behavior further.

> [!TIP]
> - Read the [scriptlet standard][SPEC] to learn more.
> - See one of the many use cases: [animation][BOOMFLAME] files.

## Getting Started
This API provides two static class methods:
  1. Parse by file.
  2. Parse by string.

> [!NOTE]
> Loading by file is asynchronous.

```dart
void main() async {
  final YesParser parser = await YesParser.fromFile(
    File.fromUri(
      Uri.file("doc.mesh"),
    ),
  );

  // Successfully parsed elements are stored in [elementInfoList].
  // Errors are stored in [errorInfoList].
  onComplete(parser.elementInfoList, parser.errorInfoList);
}

void onComplete(List<ElementInfo> elements, List<ErrorInfo> errors) { ... }
```

> [!NOTE]
> Loading by string is synchronous.

```dart
void main() {
  // docStr is a large document with each line separated by new-lines.
  final String docStr = "...";
  final YesParser parser = YesParser.fromString(docStr);
  onComplete(parser.elementInfoList, parser.errorInfoList);
}

void onComplete(List<ElementInfo> elements, List<ErrorInfo> errors) { ... }
```

### Run the Example

Enter the example directory and run from command line.
```bsh
cd example
dart yes_parser_example.dart
```

This simple [example](./example/yes_parser_example.dart) shows how to step through
each element and ignore unimportant errors for a [3D Mesh format](./example/doc.mesh)
similar to Wavefront's 3D `.OBJ` format.

## License
This project is licensed under the [Common Development and Distribution License (CDDL)][LEGAL].

[BOOMFLAME]: https://github.com/TheMaverickProgrammer/boomflame
[LEGAL]: https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/LICENSE
[SPEC]: https://github.com/TheMaverickProgrammer/dart_yes_parser/blob/master/spec/README.md