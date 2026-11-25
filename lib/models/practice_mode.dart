/// What the user practises: a countdown, a fixed number of words, or a quote.
sealed class PracticeMode {
  const PracticeMode();

  /// Stable id used to group results and personal bests, e.g. `time:30`.
  String get key;

  /// Short human label, e.g. `time 30`.
  String get label;

  /// Parses a [key]; unknown keys fall back to [fallback].
  static PracticeMode parse(String key) {
    final [kind, value, ...] = [...key.split(':'), ''];
    return switch (kind) {
      'time' when TimeMode.options.contains(int.tryParse(value)) => TimeMode(
        int.parse(value),
      ),
      'words' when WordsMode.options.contains(int.tryParse(value)) => WordsMode(
        int.parse(value),
      ),
      'quote' => QuoteMode(
        QuoteLength.values.asNameMap()[value] ?? QuoteLength.medium,
      ),
      _ => fallback,
    };
  }

  static const PracticeMode fallback = WordsMode(25);
}

final class TimeMode extends PracticeMode {
  const TimeMode(this.seconds);

  static const options = [15, 30, 60];

  final int seconds;

  Duration get limit => Duration(seconds: seconds);

  @override
  String get key => 'time:$seconds';

  @override
  String get label => 'time $seconds';

  @override
  bool operator ==(Object other) =>
      other is TimeMode && other.seconds == seconds;

  @override
  int get hashCode => key.hashCode;
}

final class WordsMode extends PracticeMode {
  const WordsMode(this.count);

  static const options = [10, 25, 50];

  final int count;

  @override
  String get key => 'words:$count';

  @override
  String get label => 'words $count';

  @override
  bool operator ==(Object other) => other is WordsMode && other.count == count;

  @override
  int get hashCode => key.hashCode;
}

final class QuoteMode extends PracticeMode {
  const QuoteMode(this.length);

  final QuoteLength length;

  @override
  String get key => 'quote:${length.name}';

  @override
  String get label => 'quote ${length.name}';

  @override
  bool operator ==(Object other) =>
      other is QuoteMode && other.length == length;

  @override
  int get hashCode => key.hashCode;
}

/// Quote length buckets, in characters (Monkeytype's grouping).
enum QuoteLength {
  short(0, 100),
  medium(101, 300),
  long(301, 600);

  const QuoteLength(this.min, this.max);

  final int min;
  final int max;

  bool fits(String text) => text.length >= min && text.length <= max;
}
