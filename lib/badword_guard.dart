import 'dart:convert';

import 'worddata.dart';

class LanguageChecker {
  late final List<String> _badWords;

  LanguageChecker() {
    _badWords = _decodeBadWords();
  }

  List<String> _decodeBadWords() {
    var decoded = utf8.decode(base64.decode(badwordlist));
    return decoded.split('\n').where((word) => word.trim().isNotEmpty).toList();
  }

  bool containsBadLanguage(String input) {
    if (input.trim().isEmpty) return false;

    for (var badWord in _badWords) {
      if (_containsExactWord(input, badWord)) {
        return true;
      }
    }
    return false;
  }

  String filterBadWords(String input) {
    if (input.trim().isEmpty) return input;

    String result = input;
    for (var badWord in _badWords) {
      if (badWord.trim().isEmpty) continue;

      // Simple case-insensitive replacement
      result = result.replaceAll(
          RegExp(RegExp.escape(badWord), caseSensitive: false),
          '*' * badWord.length);
    }
    return result;
  }

  bool _containsExactWord(String input, String word) {
    if (input.trim().isEmpty || word.trim().isEmpty) return false;

    // Simple approach: just check if the word exists in the input (case-insensitive)
    return input.toLowerCase().contains(word.toLowerCase());
  }

  bool _containsNonLatinChars(String text) {
    return text.runes.any((rune) => rune > 127);
  }

  bool _containsNonLatinWord(String input, String word) {
    final lowerInput = input.toLowerCase();
    final lowerWord = word.toLowerCase();

    int index = lowerInput.indexOf(lowerWord);
    while (index != -1) {
      // Check if this occurrence is a complete word
      bool isWordStart = index == 0 || _isWordSeparator(lowerInput, index - 1);
      bool isWordEnd = index + lowerWord.length >= lowerInput.length ||
          _isWordSeparator(lowerInput, index + lowerWord.length);

      if (isWordStart && isWordEnd) return true;

      index = lowerInput.indexOf(lowerWord, index + 1);
    }
    return false;
  }

  String _replaceNonLatinWord(String input, String word) {
    final lowerInput = input.toLowerCase();
    final lowerWord = word.toLowerCase();
    String result = input;
    int offset = 0;

    int index = lowerInput.indexOf(lowerWord);
    while (index != -1) {
      // Check if this occurrence is a complete word
      bool isWordStart = index == 0 || _isWordSeparator(lowerInput, index - 1);
      bool isWordEnd = index + lowerWord.length >= lowerInput.length ||
          _isWordSeparator(lowerInput, index + lowerWord.length);

      if (isWordStart && isWordEnd) {
        int actualIndex = index + offset;
        String replacement = '*' * word.length;
        result = result.substring(0, actualIndex) +
            replacement +
            result.substring(actualIndex + word.length);
        offset += replacement.length - word.length;
      }

      index = lowerInput.indexOf(lowerWord, index + 1);
    }
    return result;
  }

  bool _isWordSeparator(String text, int index) {
    if (index < 0 || index >= text.length) return true;

    final char = text[index];
    final codeUnit = char.codeUnitAt(0);

    // Common separators
    if (char == ' ' || char == '\t' || char == '\n' || char == '\r')
      return true;
    if (char == '.' || char == ',' || char == '!' || char == '?') return true;
    if (char == ';' || char == ':' || char == '"' || char == "'") return true;
    if (char == '(' || char == ')' || char == '[' || char == ']') return true;
    if (char == '{' || char == '}' || char == '<' || char == '>') return true;
    if (char == '/' || char == '\\' || char == '|' || char == '-') return true;
    if (char == '_' || char == '+' || char == '=' || char == '*') return true;
    if (char == '&' || char == '%' || char == '\$' || char == '#') return true;
    if (char == '@' || char == '^' || char == '~' || char == '`') return true;

    // Unicode categories for separators and punctuation
    // This is a simplified check - for full Unicode support, you'd want to use
    // a more comprehensive Unicode category checking library
    if (codeUnit >= 0x2000 && codeUnit <= 0x206F)
      return true; // General Punctuation
    if (codeUnit >= 0x3000 && codeUnit <= 0x303F)
      return true; // CJK Symbols and Punctuation
    if (codeUnit >= 0xFE30 && codeUnit <= 0xFE4F)
      return true; // CJK Compatibility Forms
    if (codeUnit >= 0xFE50 && codeUnit <= 0xFE6F)
      return true; // Small Form Variants
    if (codeUnit >= 0xFF00 && codeUnit <= 0xFFEF)
      return true; // Halfwidth and Fullwidth Forms

    // Arabic punctuation and separators
    if (codeUnit >= 0x060C && codeUnit <= 0x061F) return true;
    if (codeUnit >= 0x06D4 && codeUnit <= 0x06D4) return true;

    return false;
  }

  // Additional utility methods
  List<String> getBadWords() {
    return List.unmodifiable(_badWords);
  }

  int getBadWordCount() {
    return _badWords.length;
  }

  List<String> findBadWords(String input) {
    List<String> foundWords = [];
    for (var badWord in _badWords) {
      if (_containsExactWord(input, badWord)) {
        foundWords.add(badWord);
      }
    }
    return foundWords;
  }
}
