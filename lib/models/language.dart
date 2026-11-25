import 'word_list.dart';

/// The language practice texts are in. Names match the asset files that
/// `tool/import_monkeytype.py` writes.
enum Language {
  english('english'),
  spanish('español'),
  french('français'),
  german('deutsch'),
  portuguese('português'),
  italian('italiano'),
  russian('русский'),
  polish('polski', wordLists: [WordList.common200]),
  dutch('nederlands'),
  turkish('türkçe'),
  indonesian('indonesia');

  const Language(this.label, {this.wordLists = WordList.values});

  /// The language's own name for itself.
  final String label;

  /// The frequency lists Monkeytype has for this language.
  final List<WordList> wordLists;

  /// [wanted] if this language has it, else its shortest list.
  WordList listFor(WordList wanted) =>
      wordLists.contains(wanted) ? wanted : wordLists.first;
}
