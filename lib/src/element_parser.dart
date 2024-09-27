import 'dart:math';
import 'package:yes_parser/extensions.dart';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/src/enums.dart';
import 'package:yes_parser/src/element.dart';

/// [ElementInfo] retains the [lineNumber] an [element] was parsed on.
class ElementInfo {
  final Element element;
  final int lineNumber;

  ElementInfo(this.lineNumber, this.element);
}

/// [ElementParser] parses the [elementInfo] from a line.
/// Used internally.
class ElementParser {
  Delimiters _delimiter = Delimiters.unset;
  Element? _element;
  ErrorType? _error;
  final int lineNumber;

  bool get isDelimiterSet {
    return _delimiter != Delimiters.unset;
  }

  bool get isOk {
    return _error == null;
  }

  ErrorType? get error {
    return _error;
  }

  String get delimiter {
    return switch (_delimiter) {
      Delimiters.comma => Glyphs.comma.char,
      Delimiters.space => Glyphs.space.char,
      _ => Glyphs.none.char,
    };
  }

  ElementInfo get elementInfo {
    if (_element == null) {
      throw Exception('Null element! Use getter `isOk` before accessing!');
    }

    return ElementInfo(lineNumber, _element!);
  }

  ElementParser.read(this.lineNumber, String line) {
    // Step 1: Trim whitespace and start at the first valid character
    line = line.trim();
    final int len = line.length;

    if (len == 0) {
      setError(ErrorType.eolNoData);
      return;
    }

    int pos = 0;
    ElementType type = ElementType.standard;

    while (pos < len) {
      // Find first non-space character
      if (line[pos] == Glyphs.space.char) {
        pos++;
        continue;
      }

      final int idx = Glyphs.values.indexWhere((el) => el.char == line[pos]);

      // Standard token
      if (idx == -1) {
        break;
      }

      // Step 2: if the first valid character is reserved prefix
      // then tag the element and continue searching for the name start pos
      final Glyphs glyph = Glyphs.values[idx];
      switch (glyph) {
        case Glyphs.hash:
          if (type == ElementType.standard) {
            // Take everything beyond the hash as the comment content
            _element = Element.comment(line.substring(pos + 1));
            return;
          }
        case Glyphs.at:
          if (type != ElementType.standard) {
            setError(ErrorType.badTokenPosAttribute);
            return;
          }
          type = ElementType.attribute;
          pos++;
          continue;
        case Glyphs.bang:
          if (type != ElementType.standard) {
            setError(ErrorType.badTokenPosBang);
            return;
          }
          type = ElementType.global;
          pos++;
          continue;
        case _:
        /* fall through to end the loop */
      }

      // end the loop
      break;
    }

    // Step 3: find end of element name (first space or EOL)
    pos = min(pos, len);
    final int idx = line.indexOf(Glyphs.space.char, pos);

    final int end;
    if (idx < 0) {
      end = len;
    } else {
      end = min(len, idx);
    }

    final String name = line.substring(pos, end).unquote();
    if (name.isEmpty) {
      ErrorType errorType = ErrorType.eolMissingElement;

      if (type == ElementType.attribute) {
        errorType = ErrorType.eolMissingAttribute;
      } else if (type == ElementType.global) {
        errorType = ErrorType.eolMissingGlobal;
      }

      setError(errorType);
      return;
    }

    // Comment element case handled already above
    switch (type) {
      case ElementType.attribute:
        _element = Element.attribute(name);
        break;
      case ElementType.global:
        _element = Element.global(name);
        break;
      case _:
        _element = Element.standard(name);
    }

    // Step 4: parse tokens, if any and return results
    parseTokens(line, end);
  }

  void parseTokens(String input, int start) {
    int end = start;

    // Evaluate all tokens on line
    while (end < input.length) {
      end = parseTokenStep(input, end + 1);

      // Abort early if there is a problem
      if (!isOk) {
        return;
      }
    }
  }

  int parseTokenStep(String input, int start) {
    final int len = input.length;

    // Find first non-space character
    while (start < len) {
      if (Glyphs.space.char == input[start]) {
        start++;
        continue;
      }

      // Current character is non-space
      break;
    }

    if (start >= len) {
      return len;
    }

    final int end = evaluateDelimiter(input, start);
    evaluateToken(input, start, end);
    return end;
  }

  int evaluateDelimiter(String input, int start) {
    bool quoted = false; // Finds matching end-quotes
    final int len = input.length;
    int current = start;

    // Step 1: skip string literals beginning and ending with quotes
    while (current < len) {
      int quotePos = input.indexOf(Glyphs.quote.char, current);
      if (quoted) {
        if (quotePos == -1) {
          setError(ErrorType.unterminatedQuote);
          return len;
        }
        quoted = false;
        start = quotePos;
        current = start + 1;
        continue;
      }

      assert(!quoted, 'Parser has unterminated quote without an early exit.');

      final int spacePos = input.indexOf(Glyphs.space.char, current);
      final int commaPos = input.indexOf(Glyphs.comma.char, current);

      if (spacePos > -1 && quotePos > spacePos) {
        quotePos = -1;
      }

      if (commaPos > -1 && quotePos > commaPos) {
        quotePos = -1;
      }

      if (quotePos > -1) {
        quoted = true;
        start = quotePos;
        current = start + 1;
        continue;
      }

      // Use the first (nearest) valid delimiter
      if (spacePos == -1 && commaPos > -1) {
        current = commaPos;
      } else if (spacePos > -1 && commaPos == -1) {
        current = spacePos;
      } else if (spacePos > -1 && commaPos > -1) {
        current = min(spacePos, commaPos);
      }
      break;
    }

    // Step 2: assign delimiter if not yet set
    // by scanning white spaces in search for the first comma.
    //
    // If EOL is reached, comma is chosen to be the delimiter so that
    // tokens with one KeyVal argument can have spaces around it,
    // since it is the case when it is obvious there are no other
    // arguments to parse.

    int space = -1, equal = -1, quote = -1, equalCount = 0;
    while (!isDelimiterSet && current < len) {
      final String c = input[current];
      final bool isComma = Glyphs.comma.char == c;
      final bool isSpace = Glyphs.space.char == c;
      final bool isEqual = Glyphs.equal.char == c;
      final bool isQuote = Glyphs.quote.char == c;

      if (isComma) {
        setDelimiterType(Delimiters.comma);
        break;
      }

      if (quote == -1) {
        if (isSpace && space == -1) {
          space = current;
        }

        if (isEqual) {
          if (equal == -1) {
            equal = current;
          }

          equalCount++;
        }
      }

      // Ensure quotes are toggled, if token was reached
      if (isQuote) {
        if (quote == -1) {
          quote = current;
        } else {
          quote = -1;
        }
      }

      current++;
    }

    // EOL with no comma delimiter found
    if (!isDelimiterSet) {
      // No space token found so there is no other delimiter.
      // Spaces will be used.
      if (space == -1) {
        return len;
      } else if (equalCount == 1) {
        // Step #2 edge case: no delimiter was found
        // and only **one** key provided, which means
        // the key-value pair is likely to be surrounded by
        // whitespace and should be permitted.
        setDelimiterType(Delimiters.comma);
      } else {
        setDelimiterType(Delimiters.space);
      }

      // Go back to the first space token
      current = space;
    }

    // Step 3: use delimiter type to find next end position
    // which will result in the range [start,end] to be the next token
    final int idx = input.indexOf(delimiter, start);
    if (idx == -1) {
      // Possibly last keyval token. EOL.
      return len;
    }

    return min(len, idx);
  }

  void evaluateToken(String input, int start, int end) {
    // Should never happen
    assert(_element != null, 'Element was not initialized.');

    // Trim white spaces around the token for key-val
    // assignments. e.g. `key=val`
    final String token = input.substring(start, end).trim();

    // Named key values are seperated by equal (=) tokens
    final int equalPos = token.indexOf(Glyphs.equal.char);
    if (equalPos != -1) {
      final KeyVal kv = KeyVal(
        key: token.substring(0, equalPos).trim().unquote(),
        val: token.substring(equalPos + 1, token.length).trim().unquote(),
      );

      _element?.upsert(kv);
      return;
    }

    // Nameless key value
    final KeyVal kv = KeyVal(val: token.unquote());
    _element?.add(kv);
  }

  void setOk() {
    _error = null;
  }

  void setError(ErrorType type) {
    _error = type;
  }

  bool setDelimiterType(Delimiters type) {
    if (!isDelimiterSet) {
      _delimiter = type;
      return true;
    }

    return _delimiter == type;
  }
}
