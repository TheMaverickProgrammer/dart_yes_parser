# 1.0.4

- `Entity.getKeyValueAsBool()` parses non-zero integer values as true and zero integer values as false.
- Added new tests to catch further parsing errors. Further updates will improve testing suite.
- `getKeyValueAsBool()` now correctly sets `caseSenitive` param in `bool.parse()` to `true`.
- Added support for getKeyValueAsBool() to return true for non-zero `int` values.
  
# 1.0.3

- Missed or.unquote() for Element.getKeyValue() which affected all the other keyval getters. Fixed.

# 1.0.2

- Auto-strip quotes from KeyVal values for convenience. Added an extension to the lib to easy restore them if needed.
- Inline Dart-style documentation.

# 1.0.1

- Fixed issue parsing a document by string. Constructors `fromFile` and `fromString` both require `onComplete`.

## 1.0.0

- Initial version.
