# 1.0.7

- Preventing a crash by explicitly copying a List of literals that can otherwise happen if the user provides a `const` List or ungrowable List.
- Added inline documentation for the two factory methods for the parser API.
- After parsing a discovered token range, consume space characters. This patches the case where blanks were parsed as empty key-vals.

# 1.0.6

- Added multiline support to the spec and the parser.
- Added custom user literals support to the spec and the parser.
- Updated readme and tests to include these changes.

# 1.0.5

- Added several tests to catch edge-cases. Found and patched: 
  - One named key-val pair edge-case did not parse correctly. 
  - We determine the best fit delimiter by token-walking when there is a potentially ambigious key-val.
  - Key-vals correctly strip quoted text.
- Removed the `onComplete()` callback. `elementInfoList` and `errorInfoList` can be directly read in the parser instead.
- Remove `join()` which blocked the thread until a file was parsed.
- The constructors for `YesParser` are now `static` methods which return the new parser object.

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
