/// The numbers of one round, Monkeytype's definitions.
class TypingStats {
  const TypingStats({
    required this.elapsed,
    required this.wpm,
    required this.rawWpm,
    required this.accuracy,
    required this.correctChars,
    required this.incorrectChars,
    required this.extraChars,
    required this.missedChars,
    required this.wpmPerSecond,
  });

  final Duration elapsed;

  /// Characters of correctly typed words (and their spaces) per minute / 5.
  final double wpm;

  /// Every character typed, right or wrong, per minute / 5.
  final double rawWpm;

  /// Percentage of keystrokes that were correct, 0 to 100.
  final double accuracy;

  final int correctChars;
  final int incorrectChars;

  /// Typed past the end of a word.
  final int extraChars;

  /// Left out of words that were skipped with a space.
  final int missedChars;

  /// Running wpm (correct keystrokes) at the end of each second, for a chart.
  final List<double> wpmPerSecond;
}
