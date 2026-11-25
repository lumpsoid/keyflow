/// Which Monkeytype frequency list words are drawn from.
enum WordList {
  common200('200 common'),
  common1k('1k common');

  const WordList(this.label);

  final String label;
}
