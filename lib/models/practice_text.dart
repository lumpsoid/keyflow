/// The words of one practice round, with where they came from.
class PracticeText {
  PracticeText(List<String> words, {this.source})
    : assert(words.isNotEmpty && words.every((w) => w.isNotEmpty)),
      words = List.unmodifiable(words);

  final List<String> words;

  /// Attribution shown with a quote; null for generated word lists.
  final String? source;
}
