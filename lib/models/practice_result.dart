import 'language.dart';

/// One finished round, as stored in history.
class PracticeResult {
  const PracticeResult({
    required this.modeKey,
    this.language = Language.english,
    required this.wpm,
    required this.rawWpm,
    required this.accuracy,
    required this.duration,
    required this.finishedAt,
  });

  factory PracticeResult.fromJson(Map<String, Object?> json) => PracticeResult(
    modeKey: json['mode'] as String,
    // Results from before languages were English.
    language: Language.values.asNameMap()[json['lang']] ?? Language.english,
    wpm: (json['wpm'] as num).toDouble(),
    rawWpm: (json['raw'] as num).toDouble(),
    accuracy: (json['acc'] as num).toDouble(),
    duration: Duration(milliseconds: json['ms'] as int),
    finishedAt: DateTime.fromMillisecondsSinceEpoch(json['at'] as int),
  );

  final String modeKey;
  final Language language;
  final double wpm;
  final double rawWpm;

  /// Percentage of keystrokes that were correct, 0 to 100.
  final double accuracy;
  final Duration duration;
  final DateTime finishedAt;

  Map<String, Object?> toJson() => {
    'mode': modeKey,
    'lang': language.name,
    'wpm': double.parse(wpm.toStringAsFixed(2)),
    'raw': double.parse(rawWpm.toStringAsFixed(2)),
    'acc': double.parse(accuracy.toStringAsFixed(2)),
    'ms': duration.inMilliseconds,
    'at': finishedAt.millisecondsSinceEpoch,
  };
}
