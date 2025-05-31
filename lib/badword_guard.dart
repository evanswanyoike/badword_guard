import 'package:badword_guard/worlist.dart';

class LanguageChecker {
  late final List<String> _badWords;

  LanguageChecker() {
    _badWords = _decodeBadWords();
  }

  List<String> _decodeBadWords() {
    return badLanguage
        .split('\n')
        .where((word) => word.trim().isNotEmpty)
        .toList();
  }

  bool containsBadLanguage(String input) {
    if (input.trim().isEmpty) return false;

    final lowerInput = input.toLowerCase();
    for (var badWord in _badWords) {
      if (lowerInput.contains(badWord.toLowerCase())) {
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

      result = result.replaceAll(
          RegExp(RegExp.escape(badWord), caseSensitive: false),
          '*' * badWord.length);
    }
    return result;
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
    final lowerInput = input.toLowerCase();

    for (var badWord in _badWords) {
      if (lowerInput.contains(badWord.toLowerCase())) {
        foundWords.add(badWord);
      }
    }
    return foundWords;
  }

  // Method to add words dynamically
  void addBadWord(String word) {
    if (!_badWords.contains(word.toLowerCase())) {
      _badWords.add(word.toLowerCase());
    }
  }

  // Method to add multiple words
  void addBadWords(List<String> words) {
    for (String word in words) {
      addBadWord(word);
    }
  }

  // Method to remove a word
  void removeBadWord(String word) {
    _badWords.remove(word.toLowerCase());
  }
}
