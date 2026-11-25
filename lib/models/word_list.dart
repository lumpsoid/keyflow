/// Which Monkeytype frequency list words are drawn from.
enum WordList {
  common200('200 common', '200'),
  common1k('1k common', '1k');

  const WordList(this.label, this.fileSuffix);

  final String label;

  /// Ends the asset name, e.g. `english_1k.json`.
  final String fileSuffix;
}
