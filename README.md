# YES Script
`YES` - **Y**our **E**xtensible **S**cript .

YES is a meta [scriptlet standard][SPEC] whose elements and meaning are determined
by **YOU** the programmer. They can be extended further with attributes which
allow **YOUR** end-users to make their additions to **YOUR** elements.

## Getting Started
The dart API provides two constructors: parsing by file or parsing by string.
These constructors require the callback function to be set via `.then(...)`.

Loading by file is asynchronous and must be waited on for completion
```dart
void main() async {
  final p = YesParser.fromFile(File.fromUri(Uri.file("example.mesh")))
    ..then(onComplete);

  // Wait for parser to finish before ending program
  await p.join();
}

void onComplete(List<Element> elements, List<ErrorInfo> errors) { ... }
```

Loading by string is synchronous and can be used immediately.
```dart
void main() {
  final p = YesParser.fromFile("...")
    ..then(onComplete);
}

void onComplete(List<Element> elements, List<ErrorInfo> errors) { ... }
```

See the [example](./example/yes_parser_example.dart) to learn how to access
element types and their data from a [mesh file format](./example/example.mesh)
which uses the YES scriplet spec.

## License
This project is licensed under the [Common Development and Distribution License (CDDL)][LEGAL].

[SPEC]: https://github.com/TheMaverickProgrammer/js_yes_parser/blob/master/spec/README.md
[LEGAL]: https://github.com/TheMaverickProgrammer/js_yes_parser/blob/master/legal/LICENSE.md