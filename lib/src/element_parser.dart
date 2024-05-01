import 'dart:math';
import 'package:yes_parser/src/keyval.dart';
import 'package:yes_parser/src/enums.dart';
import 'package:yes_parser/src/element.dart';

class ElementParser {
  Delimiters _delimiter = Delimiters.unset;
  Element? _element;
  Errors? _error;

  bool get isDelimiterSet {
    return _delimiter != Delimiters.unset;
  }

  bool get isOk {
    return _error == null;
  }

  Errors? get error {
    return _error;
  }

  String get delimiter {
    return switch (_delimiter) {
      Delimiters.spaceComma => ',',
      Delimiters.spaceOnly => ' ',
      _ => '',
    };
  }

  Element get element {
    if (_element == null) {
      throw Exception("Null element! Use `isOk` before accessing!");
    }

    return _element!;
  }

  ElementParser.read(String line) {
    // Step 1: Trim whitespace and start at the first valid character
    line = line.trim();
    final int len = line.length;

    if (len == 0) {
      setError(Errors.eolNoData);
      return;
    }

    int pos = 0;
    Elements type = Elements.standard;

    while (pos < len) {
      // Find first non-space character
      if (line[pos] == ' ') {
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
          if (type == Elements.standard) {
            _element = Element.comment(line.substring(pos));
            return;
          }
        case Glyphs.at:
          if (type != Elements.standard) {
            setError(Errors.badTokenPosAttribute);
            return;
          }
          type = Elements.attribute;
          pos++;
          continue;
        case Glyphs.bang:
          if (type != Elements.standard) {
            setError(Errors.badTokenPosBang);
          }
          type = Elements.global;
          pos++;
          continue;
        case _:
      }

      // end the loop
      break;
    }
    // Step 3: find end of element name (first space or EOL)
    pos = min(pos, len);
    final int end = min(len, line.indexOf(Glyphs.space.char, pos));
    final String name = line.substring(pos, end);
    if (name.isEmpty) {
      Errors errorType = Errors.eolMissingElement;

      if (type == Elements.attribute) {
        errorType = Errors.eolMissingAttribute;
      } else if (type == Elements.global) {
        errorType = Errors.eolMissingGlobal;
      }

      setError(errorType);
      return;
    }

    switch (type) {
      case Elements.attribute:
        _element = Element.attribute(name);
        break;
      case Elements.global:
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
      start = end = parseTokenStep(input, start);
      start++;
      // Abort early if there is a problem
      if (!isOk) {
        return;
      }
    }
  }

  int parseTokenStep(String input, int start) {
    int tokenStart = input.indexOf(Glyphs.space.char, start);

    // If we've reached the end of input, use the end pos to indicate such
    if (tokenStart == -1) {
      tokenStart = input.length;
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
          setError(Errors.unterminatedQuote);
          return len;
        }
        quoted = false;
        start = quotePos;
        current = start + 1;
        continue;
      }

      int spacePos = input.indexOf(Glyphs.space.char, current);
      int commaPos = input.indexOf(Glyphs.comma.char, current);

      if (quotePos > -1 && quotePos < spacePos && quotePos < commaPos) {
        quoted = true;
        start = quotePos;
        current = start + 1;
        continue;
      } else if (spacePos == commaPos) {
        // edge case: end of line read
        return len;
      }

      // use the first (nearest) valid delimiter
      if (spacePos == -1 && commaPos > -1) {
        current = commaPos;
      } else if (spacePos > -1 && commaPos == -1) {
        current = spacePos;
      } else if (spacePos > -1 && commaPos > -1) {
        current = min(spacePos, commaPos);
      }
      break;
    }

    // Step 2: determine delimiter if not yet set
    // by scanning white spaces in search for the first comma
    // or first token character (non-space)
    while (!isDelimiterSet && current < len) {
      final String c = input[current];
      final bool isComma = Glyphs.comma.char == c;
      final bool isSpace = Glyphs.space.char == c;

      if (isComma) {
        setDelimiterType(Delimiters.spaceComma);
        break;
      } else if (isSpace) {
        setDelimiterType(Delimiters.spaceOnly);
        break;
      }

      current++;
    }

    // EOL with no delimiter found
    if (!isDelimiterSet) {
      return len;
    }

    // Step 3: use delimiter type to find next end position
    // which will result in the range [start,end] to be the next token
    return min(len, input.indexOf(delimiter, start));
  }

  void evaluateToken(String input, int start, int end) {
    // Should never happen
    assert(_element != null, "Element was not initialized.");

    final String token = input.substring(start, end);

    // Named kay values are seperated by equals tokens
    final int equalPos = token.indexOf(Glyphs.equal.char);
    if (equalPos != -1) {
      final KeyVal kv = KeyVal(
          key: token.substring(0, equalPos),
          val: token.substring(equalPos + 1, end - start));

      _element?.upsert(kv);
      return;
    }

    // Nameless key value
    final KeyVal kv = KeyVal(val: token);
    _element?.add(kv);
  }

  void setOk() {
    _error = null;
  }

  void setError(Errors type) {
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
